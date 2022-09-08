# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Git::Wiki do
  using RSpec::Parameterized::TableSyntax

  let(:project) { create(:project) }
  let(:user) { project.first_owner }
  let(:project_wiki) { ProjectWiki.new(project, user) }
  let(:repository) { project_wiki.repository }
  let(:default_branch) { described_class.default_ref(project) }

  subject(:wiki) { project_wiki.wiki }

  before do
    repository.create_if_not_exists(project_wiki.default_branch)
  end

  describe '#pages' do
    before do
      create_page('page1', 'content')
      create_page('page2', 'content2')
    end

    after do
      destroy_page('page1')
      destroy_page('page2')
    end

    it 'returns all the pages' do
      expect(subject.list_pages.count).to eq(2)
      expect(subject.list_pages.first.title).to eq 'page1'
      expect(subject.list_pages.last.title).to eq 'page2'
    end

    it 'returns only one page' do
      pages = subject.list_pages(limit: 1)

      expect(pages.count).to eq(1)
      expect(pages.first.title).to eq 'page1'
    end
  end

  describe '#page' do
    before do
      create_page('page1', 'content')
      create_page('foo/page1', 'content foo/page1')
    end

    after do
      destroy_page('page1')
      destroy_page('foo/page1')
    end

    it 'returns the right page' do
      page = subject.page(title: 'page1', dir: '')
      expect(page.url_path).to eq 'page1'
      expect(page.raw_data).to eq 'content'

      page = subject.page(title: 'page1', dir: 'foo')
      expect(page.url_path).to eq 'foo/page1'
      expect(page.raw_data).to eq 'content foo/page1'
    end

    it 'returns nil for invalid arguments' do
      expect(subject.page(title: '')).to be_nil
      expect(subject.page(title: 'foo', version: ':')).to be_nil
    end

    it 'does not return content if load_content param is set to false' do
      page = subject.page(title: 'page1', dir: '', load_content: false)

      expect(page.url_path).to eq 'page1'
      expect(page.raw_data).to be_empty
    end
  end

  describe '#preview_slug' do
    where(:title, :file_extension, :format, :expected_slug) do
      'The Best Thing'       | :md  | :markdown | 'The-Best-Thing'
      'The Best Thing'       | :md  | :md       | 'The-Best-Thing'
      'The Best Thing'       | :txt | :txt      | 'The-Best-Thing'
      'A Subject/Title Here' | :txt | :txt      | 'A-Subject/Title-Here'
      'A subject'            | :txt | :txt      | 'A-subject'
      'A 1/B 2/C 3'          | :txt | :txt      | 'A-1/B-2/C-3'
      'subject/title'        | :txt | :txt      | 'subject/title'
      'subject/title.md'     | :txt | :txt      | 'subject/title.md'
      'foo<bar>+baz'         | :txt | :txt      | 'foo-bar--baz'
      'foo%2Fbar'            | :txt | :txt      | 'foo%2Fbar'
      ''                     | :md  | :markdown | '.md'
      ''                     | :md  | :md       | '.md'
      ''                     | :txt | :txt      | '.txt'
    end

    with_them do
      subject { wiki.preview_slug(title, format) }

      let(:gitaly_slug) { wiki.list_pages.first }

      it { is_expected.to eq(expected_slug) }

      it 'matches the slug generated by gitaly' do
        skip('Gitaly cannot generate a slug for an empty title') unless title.present?

        create_page(title, 'content', file_extension)

        gitaly_slug = wiki.list_pages.first.url_path

        is_expected.to eq(gitaly_slug)
      end
    end
  end

  def create_page(name, content, extension = :md)
    repository.create_file(
      user, ::Wiki.sluggified_full_path(name, extension.to_s), content,
      branch_name: default_branch,
      message: "created page #{name}",
      author_email: user.email,
      author_name: user.name
    )
  end

  def destroy_page(name, extension = :md)
    repository.delete_file(
      user, ::Wiki.sluggified_full_path(name, extension.to_s),
      branch_name: described_class.default_ref(project),
      message: "delete page #{name}",
      author_email: user.email,
      author_name: user.name
    )
  end
end
