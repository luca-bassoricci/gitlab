# frozen_string_literal: true

class Profiles::SavedRepliesController < Profiles::ApplicationController
  include Gitlab::Utils::StrongMemoize
  include PreviewMarkdown

  before_action :set_saved_reply, only: [:edit, :update, :destroy]
  before_action :set_saved_replies, only: [:index, :create]

  feature_category :users

  def index
    @saved_reply = ::SavedReplies::BuildService.new(
      container: nil,
      current_user: current_user
    ).execute
  end

  def create
    @saved_reply = ::SavedReplies::CreateService.new(
      container: nil,
      current_user: current_user,
      params: saved_reply_params
    ).execute

    if @saved_reply.valid?
      redirect_to(profile_saved_replies_path, notice: _('Saved reply was successfully created.'))
    else
      render 'index'
    end
  end

  def edit
  end

  def update
    service = ::SavedReplies::UpdateService.new(
      container: nil,
      current_user: current_user,
      params: saved_reply_params
    ).execute(@saved_reply)

    if service.valid?
      redirect_to(profile_saved_replies_path, notice: _('Saved reply was successfully updated.'))
    else
      render 'edit'
    end
  end

  def destroy
    service = ::SavedReplies::DestroyService.new(
      container: nil,
      current_user: current_user
    )

    if service.execute(@saved_reply)
      redirect_to(profile_saved_replies_path, status: :found, notice: _('Saved reply was successfully deleted.'))
    end
  end

  private

  def saved_reply_params
    params.require(:users_saved_reply).permit(:note, :title)
  end

  def set_saved_reply
    strong_memoize(:saved_reply) do
      current_user.saved_replies.find(params['id'])
    end
  end

  def set_saved_replies
    strong_memoize(:saved_replies) do
      current_user.saved_replies
    end
  end
end
