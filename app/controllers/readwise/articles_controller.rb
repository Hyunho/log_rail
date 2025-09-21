class Readwise::ArticlesController < ApplicationController
  def index
    json_files = Dir.glob(Rails.root.join('db', 'data', 'readwise', 'doc', '*.json'))
    @articles = json_files.map { |file| JSON.parse(File.read(file)) }
    @articles.sort_by! { |article| article['last_moved_at'] }.reverse!
  end

  def show
    @article = JSON.parse(File.read(Rails.root.join('db', 'data', 'readwise', 'doc', "#{params[:id]}.json")))
  end
end
