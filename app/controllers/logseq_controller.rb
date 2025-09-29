class LogseqController < ApplicationController
  def index
    dir_path = "/Users/hyunho/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/Base/journals/"
    md_files = Dir.glob("#{dir_path}/*.md")
    # md_files = md_files.select { |file| File.file?(file) }
    @md_files = md_files.map { |file| File.basename(file) }
    @md_files.sort!.reverse!

    render "logseq/index", locals: { md_files: @md_files }
  end
  def show
    dir_path = "/Users/hyunho/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/Base/journals/"
    md_file = File.read("#{dir_path}/#{params[:id]}.md")
    renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, extensions = {})

    
    @content = markdown.render(md_file)
    
    render "logseq/show", locals: { content: @content }
  end
end
