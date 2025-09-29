class ObsidianController < ApplicationController
  def index
    inbox_path = "#{ENV["OBSIDIAN_PATH"]}/0. Inbox"

    @files = Dir.children(inbox_path)

    # absolute path
    @files.map! { |file| File.join(inbox_path, file) }

    # remove .DS_Store
    @files.delete(".DS_Store")

    render "obsidian/index", locals: { files: @files }
  end

  def work
    inbox_path = "#{ENV["OBSIDIAN_PATH"]}/0. Inbox/Work"
    @files = Dir.children(inbox_path)

    # absolute path
    # @files.map! { |file| File.join(inbox_path, file) }

    # remove .DS_Store
    @files.delete(".DS_Store")
    @files.sort!.reverse!

    render "obsidian/work", locals: { files: @files }
  end

  def work_journal
    inbox_path = "#{ENV["OBSIDIAN_PATH"]}/_Journals/Work/daily"
    @files = Dir.children(inbox_path)

    # remove .DS_Store
    @files.delete(".DS_Store")
    @files.sort!.reverse!

    render "obsidian/work_journal", locals: { files: @files }
  end
end
