# frozen_string_literal: true

# A note on the root of an issue, merge request, commit, or snippet.
#
# A note of this type is never resolvable.
class Note < ApplicationRecord
  extend ActiveModel::Naming
  include Gitlab::Utils::StrongMemoize
  include Participable
  include Mentionable
  include Awardable
  include Importable
  include FasterCacheKeys
  include Redactable
  include CacheMarkdownField
  include AfterCommitQueue
  include ResolvableNote
  include Editable
  include Gitlab::SQL::Pattern
  include ThrottledTouch
  include FromUnion
  include Sortable

  cache_markdown_field :note, pipeline: :note, issuable_state_filter_enabled: true

  redact_field :note

  TYPES_RESTRICTED_BY_ABILITY = {
    branch: :download_code
  }.freeze

  # Aliases to make application_helper#edited_time_ago_with_tooltip helper work properly with notes.
  # See https://gitlab.com/gitlab-org/gitlab-foss/merge_requests/10392/diffs#note_28719102
  alias_attribute :last_edited_by, :updated_by

  # Attribute containing rendered and redacted Markdown as generated by
  # Banzai::ObjectRenderer.
  attr_accessor :redacted_note_html

  # Total of all references as generated by Banzai::ObjectRenderer
  attr_accessor :total_reference_count

  # Number of user visible references as generated by Banzai::ObjectRenderer
  attr_accessor :user_visible_reference_count

  # Attribute used to store the attributes that have been changed by quick actions.
  attr_accessor :commands_changes

  default_value_for :system, false

  attr_mentionable :note, pipeline: :note
  participant :author

  belongs_to :project
  belongs_to :noteable, polymorphic: true # rubocop:disable Cop/PolymorphicAssociations
  belongs_to :author, class_name: "User"
  belongs_to :updated_by, class_name: "User"
  belongs_to :last_edited_by, class_name: 'User'
  belongs_to :review, inverse_of: :notes

  has_many :todos

  # The delete_all definition is required here in order
  # to generate the correct DELETE sql for
  # suggestions.delete_all calls
  has_many :suggestions, -> { order(:relative_order) },
    inverse_of: :note, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
  has_many :events, as: :target, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
  has_one :system_note_metadata
  has_one :note_diff_file, inverse_of: :diff_note, foreign_key: :diff_note_id
  has_many :diff_note_positions

  delegate :gfm_reference, :local_reference, to: :noteable
  delegate :name, to: :project, prefix: true
  delegate :name, :email, to: :author, prefix: true
  delegate :title, to: :noteable, allow_nil: true

  validates :note, presence: true
  validates :note, length: { maximum: Gitlab::Database::MAX_TEXT_SIZE_LIMIT }
  validates :project, presence: true, if: :for_project_noteable?

  # Attachments are deprecated and are handled by Markdown uploader
  validates :attachment, file_size: { maximum: :max_attachment_size }

  validates :noteable_type, presence: true
  validates :noteable_id, presence: true, unless: [:for_commit?, :importing?]
  validates :commit_id, presence: true, if: :for_commit?
  validates :author, presence: true
  validates :discussion_id, presence: true, format: { with: /\A\h{40}\z/ }

  validate unless: [:for_commit?, :importing?, :skip_project_check?] do |note|
    unless note.noteable.try(:project) == note.project
      errors.add(:project, 'does not match noteable project')
    end
  end

  validate :does_not_exceed_notes_limit?, on: :create, unless: [:system?, :importing?]

  # @deprecated attachments are handled by the Upload model.
  #
  # https://gitlab.com/gitlab-org/gitlab/-/issues/20830
  mount_uploader :attachment, AttachmentUploader

  # Scopes
  scope :for_commit_id, ->(commit_id) { where(noteable_type: "Commit", commit_id: commit_id) }
  scope :system, -> { where(system: true) }
  scope :user, -> { where(system: false) }
  scope :common, -> { where(noteable_type: ["", nil]) }
  scope :fresh, -> { order_created_asc.with_order_id_asc }
  scope :updated_after, ->(time) { where('updated_at > ?', time) }
  scope :with_updated_at, ->(time) { where(updated_at: time) }
  scope :with_suggestions, -> { joins(:suggestions) }
  scope :inc_author_project, -> { includes(:project, :author) }
  scope :inc_author, -> { includes(:author) }
  scope :with_api_entity_associations, -> { preload(:note_diff_file, :author) }
  scope :inc_relations_for_view, -> do
    includes(:project, { author: :status }, :updated_by, :resolved_by, :award_emoji,
             { system_note_metadata: :description_version }, :note_diff_file, :diff_note_positions, :suggestions)
  end

  scope :with_notes_filter, -> (notes_filter) do
    case notes_filter
    when UserPreference::NOTES_FILTERS[:only_comments]
      user
    when UserPreference::NOTES_FILTERS[:only_activity]
      system
    else
      all
    end
  end

  scope :diff_notes, -> { where(type: %w(LegacyDiffNote DiffNote)) }
  scope :new_diff_notes, -> { where(type: 'DiffNote') }
  scope :non_diff_notes, -> { where(type: ['Note', 'DiscussionNote', nil]) }

  scope :with_associations, -> do
    # FYI noteable cannot be loaded for LegacyDiffNote for commits
    includes(:author, :noteable, :updated_by,
             project: [:project_members, :namespace, { group: [:group_members] }])
  end
  scope :with_metadata, -> { includes(:system_note_metadata) }
  scope :with_web_entity_associations, -> { preload(:project, :author, :noteable) }

  scope :for_note_or_capitalized_note, ->(text) { where(note: [text, text.capitalize]) }
  scope :like_note_or_capitalized_note, ->(text) { where('(note LIKE ? OR note LIKE ?)', text, text.capitalize) }

  before_validation :nullify_blank_type, :nullify_blank_line_code
  after_save :keep_around_commit, if: :for_project_noteable?, unless: :importing?
  after_save :expire_etag_cache, unless: :importing?
  after_save :touch_noteable, unless: :importing?
  after_destroy :expire_etag_cache
  after_commit :notify_after_create, on: :create
  after_commit :notify_after_destroy, on: :destroy

  class << self
    extend Gitlab::Utils::Override

    def model_name
      ActiveModel::Name.new(self, nil, 'note')
    end

    def discussions(context_noteable = nil)
      Discussion.build_collection(all.includes(:noteable).fresh, context_noteable)
    end

    # Note: Where possible consider using Discussion#lazy_find to return
    # Discussions in order to benefit from having records batch loaded.
    def find_discussion(discussion_id)
      notes = where(discussion_id: discussion_id).fresh.to_a

      return if notes.empty?

      Discussion.build(notes)
    end

    # Group diff discussions by line code or file path.
    # It is not needed to group by line code when comment is
    # on an image.
    def grouped_diff_discussions(diff_refs = nil)
      groups = {}

      diff_notes.fresh.discussions.each do |discussion|
        group_key =
          if discussion.on_image?
            discussion.file_new_path
          else
            discussion.line_code_in_diffs(diff_refs)
          end

        if group_key
          discussions = groups[group_key] ||= []
          discussions << discussion
        end
      end

      groups
    end

    def positions
      where.not(position: nil)
        .select(:id, :type, :position) # ActiveRecord needs id and type for typecasting.
        .map(&:position)
    end

    def count_for_collection(ids, type, count_column = 'COUNT(*) as count')
      user.select(:noteable_id, count_column)
        .group(:noteable_id)
        .where(noteable_type: type, noteable_id: ids)
    end

    def search(query)
      fuzzy_search(query, [:note])
    end

    # Override the `Sortable` module's `.simple_sorts` to remove name sorting,
    # as a `Note` does not have any property that correlates to a "name".
    override :simple_sorts
    def simple_sorts
      super.except('name_asc', 'name_desc')
    end

    def cherry_picked_merge_requests(shas)
      where(noteable_type: 'MergeRequest', commit_id: shas).select(:noteable_id)
    end
  end

  # rubocop: disable CodeReuse/ServiceClass
  def system_note_with_references?
    return unless system?

    if force_cross_reference_regex_check?
      matches_cross_reference_regex?
    else
      ::SystemNotes::IssuablesService.cross_reference?(note)
    end
  end
  # rubocop: enable CodeReuse/ServiceClass

  def diff_note?
    false
  end

  def active?
    true
  end

  def max_attachment_size
    Gitlab::CurrentSettings.max_attachment_size.megabytes.to_i
  end

  def hook_attrs
    Gitlab::HookData::NoteBuilder.new(self).build
  end

  def supports_suggestion?
    false
  end

  def for_commit?
    noteable_type == "Commit"
  end

  def for_issue?
    noteable_type == "Issue"
  end

  def for_merge_request?
    noteable_type == "MergeRequest"
  end

  def for_snippet?
    noteable_type == "Snippet"
  end

  def for_alert_mangement_alert?
    noteable_type == 'AlertManagement::Alert'
  end

  def for_project_snippet?
    noteable.is_a?(ProjectSnippet)
  end

  def for_personal_snippet?
    noteable.is_a?(PersonalSnippet)
  end

  def for_project_noteable?
    !for_personal_snippet?
  end

  def for_design?
    noteable_type == DesignManagement::Design.name
  end

  def for_issuable?
    for_issue? || for_merge_request?
  end

  def skip_project_check?
    !for_project_noteable?
  end

  def commit
    @commit ||= project.commit(commit_id) if commit_id.present?
  end

  # Notes on merge requests and commits can be traced back to one or several
  # MRs. This method returns a relation if the note is for one of these types,
  # or nil if it is a note on some other object.
  def merge_requests
    if for_commit?
      project.merge_requests.by_commit_sha(commit_id)
    elsif for_merge_request?
      MergeRequest.id_in(noteable_id)
    else
      nil
    end
  end

  # override to return commits, which are not active record
  def noteable
    return commit if for_commit?

    super
  rescue StandardError
    # Temp fix to prevent app crash
    # if note commit id doesn't exist
    nil
  end

  # FIXME: Hack for polymorphic associations with STI
  #        For more information visit http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#label-Polymorphic+Associations
  def noteable_type=(noteable_type)
    super(noteable_type.to_s.classify.constantize.base_class.to_s)
  end

  def noteable_assignee_or_author?(user)
    return false unless user
    return false unless noteable.respond_to?(:author_id)
    return noteable.assignee_or_author?(user) if [MergeRequest, Issue].include?(noteable.class)

    noteable.author_id == user.id
  end

  def contributor?
    project&.team&.contributor?(self.author_id)
  end

  def noteable_author?(noteable)
    return false unless ::Feature.enabled?(:show_author_on_note, project)

    noteable.author == self.author
  end

  def project_name
    project&.name
  end

  def confidential?(include_noteable: false)
    return true if confidential

    include_noteable && noteable.try(:confidential?)
  end

  def editable?
    !system?
  end

  # We used `last_edited_at` as an alias of `updated_at` before.
  # This makes it compatible with the previous way without data migration.
  def last_edited_at
    super || updated_at
  end

  # Since we used `updated_at` as `last_edited_at`, it could be touched by transforming / resolving a note.
  # This makes sure it is only marked as edited when the note body is updated.
  def edited?
    return false if updated_by.blank?

    super
  end

  # This method is to be used for checking read permissions on a note instead of `system_note_with_references_visible_for?`
  def readable_by?(user)
    # note_policy accounts for #system_note_with_references_visible_for?(user) check when granting read access
    Ability.allowed?(user, :read_note, self)
  end

  def award_emoji?
    can_be_award_emoji? && contains_emoji_only?
  end

  def emoji_awardable?
    !system?
  end

  def can_be_award_emoji?
    noteable.is_a?(Awardable) && !part_of_discussion?
  end

  def contains_emoji_only?
    note =~ /\A#{Banzai::Filter::EmojiFilter.emoji_pattern}\s?\Z/
  end

  def to_ability_name
    model_name.singular
  end

  def noteable_ability_name
    if for_snippet?
      'snippet'
    elsif for_alert_mangement_alert?
      'alert_management_alert'
    else
      noteable_type.demodulize.underscore
    end
  end

  def can_be_discussion_note?
    self.noteable.supports_discussions? && !part_of_discussion?
  end

  def can_create_todo?
    # Skip system notes, and notes on snippets
    !system? && !for_snippet?
  end

  def discussion_class(noteable = nil)
    # When commit notes are rendered on an MR's Discussion page, they are
    # displayed in one discussion instead of individually.
    # See also `#discussion_id` and `Discussion.override_discussion_id`.
    if noteable && noteable != self.noteable
      OutOfContextDiscussion
    else
      IndividualNoteDiscussion
    end
  end

  # See `Discussion.override_discussion_id` for details.
  def discussion_id(noteable = nil)
    discussion_class(noteable).override_discussion_id(self) || super() || ensure_discussion_id
  end

  # Returns a discussion containing just this note.
  # This method exists as an alternative to `#discussion` to use when the methods
  # we intend to call on the Discussion object don't require it to have all of its notes,
  # and just depend on the first note or the type of discussion. This saves us a DB query.
  def to_discussion(noteable = nil)
    Discussion.build([self], noteable)
  end

  # Returns the entire discussion this note is part of.
  # Consider using `#to_discussion` if we do not need to render the discussion
  # and all its notes and if we don't care about the discussion's resolvability status.
  def discussion
    strong_memoize(:discussion) do
      full_discussion = self.noteable.notes.find_discussion(self.discussion_id) if part_of_discussion?
      full_discussion || to_discussion
    end
  end

  def start_of_discussion?
    discussion.first_note == self
  end

  def part_of_discussion?
    !to_discussion.individual_note?
  end

  def in_reply_to?(other)
    case other
    when Note
      if part_of_discussion?
        in_reply_to?(other.noteable) && in_reply_to?(other.to_discussion)
      else
        in_reply_to?(other.noteable)
      end
    when Discussion
      self.discussion_id == other.id
    when Noteable
      self.noteable == other
    else
      false
    end
  end

  def references
    refs = [noteable]

    if part_of_discussion?
      refs += discussion.notes.take_while { |n| n.id < id }
    end

    refs
  end

  def expire_etag_cache
    noteable&.expire_note_etag_cache
  end

  def touch(*args, **kwargs)
    # We're not using an explicit transaction here because this would in all
    # cases result in all future queries going to the primary, even if no writes
    # are performed.
    #
    # We touch the noteable first so its SELECT query can run before our writes,
    # ensuring it runs on a secondary (if no prior write took place).
    touch_noteable
    super
  end

  # By default Rails will issue an "SELECT *" for the relation, which is
  # overkill for just updating the timestamps. To work around this we manually
  # touch the data so we can SELECT only the columns we need.
  def touch_noteable
    # Commits are not stored in the DB so we can't touch them.
    return if for_commit?

    assoc = association(:noteable)

    noteable_object =
      if assoc.loaded?
        noteable
      else
        # If the object is not loaded (e.g. when notes are loaded async) we
        # _only_ want the data we actually need.
        assoc.scope.select(:id, :updated_at).take
      end

    noteable_object&.touch

    # We return the noteable object so we can re-use it in EE for Elasticsearch.
    noteable_object
  end

  def notify_after_create
    noteable&.after_note_created(self)
  end

  def notify_after_destroy
    noteable&.after_note_destroyed(self)
  end

  def banzai_render_context(field)
    super.merge(noteable: noteable, system_note: system?, label_url_method: noteable_label_url_method)
  end

  def retrieve_upload(_identifier, paths)
    Upload.find_by(model: self, path: paths)
  end

  def resource_parent
    project
  end

  def user_mentions
    return Note.none unless noteable.present?

    noteable.user_mentions.where(note: self)
  end

  def system_note_with_references_visible_for?(user)
    return true unless system?

    (!system_note_with_references? || all_referenced_mentionables_allowed?(user)) && system_note_viewable_by?(user)
  end

  def parent_user
    noteable.author if for_personal_snippet?
  end

  def skip_notification?
    review.present? || !author.can_trigger_notifications?
  end

  private

  # Using this method followed by a call to *save* may result in *ActiveRecord::RecordNotUnique* exception
  # in a multi-threaded environment. Make sure to use it within a *safe_ensure_unique* block.
  def model_user_mention
    return if user_mentions.is_a?(ActiveRecord::NullRelation)

    user_mentions.first_or_initialize
  end

  def system_note_viewable_by?(user)
    return true unless system_note_metadata

    restriction = TYPES_RESTRICTED_BY_ABILITY[system_note_metadata.action.to_sym]
    return Ability.allowed?(user, restriction, project) if restriction

    true
  end

  def keep_around_commit
    project.repository.keep_around(self.commit_id)
  end

  def nullify_blank_type
    self.type = nil if self.type.blank?
  end

  def nullify_blank_line_code
    self.line_code = nil if self.line_code.blank?
  end

  def ensure_discussion_id
    return if self.attribute_present?(:discussion_id)

    self.discussion_id = derive_discussion_id
  end

  def derive_discussion_id
    discussion_class.discussion_id(self)
  end

  def all_referenced_mentionables_allowed?(user)
    if user_visible_reference_count.present? && total_reference_count.present?
      # if they are not equal, then there are private/confidential references as well
      user_visible_reference_count > 0 && user_visible_reference_count == total_reference_count
    else
      refs = all_references(user)
      refs.all.any? && refs.stateful_not_visible_counter == 0
    end
  end

  def force_cross_reference_regex_check?
    return unless system?

    system_note_metadata&.cross_reference_types&.include?(system_note_metadata&.action)
  end

  def does_not_exceed_notes_limit?
    return unless noteable

    errors.add(:base, _('Maximum number of comments exceeded')) if noteable.notes.count >= Noteable::MAX_NOTES_LIMIT
  end

  def noteable_label_url_method
    for_merge_request? ? :project_merge_requests_url : :project_issues_url
  end
end

Note.prepend_mod_with('Note')
