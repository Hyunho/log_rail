class Readwise::ArticlesController < ApplicationController
  def index
    json_files = Dir.glob(Rails.root.join("db", "data", "readwise", "doc", "*.json"))
    @articles = json_files.map { |file| JSON.parse(File.read(file)) }
    @archive_articles = @articles.select { |article| article["location"] == "archive" }
    @new_articles = @articles.select { |article| article["location"] == "new" }
    @feed_articles = @articles.select { |article| article["location"] == "feed" }

    @archive_articles.sort_by! { |article| article["last_moved_at"] }.reverse!
    @new_articles.sort_by! { |article| article["last_moved_at"] }.reverse!
    @feed_articles.sort_by! { |article| article["last_moved_at"] }.reverse!

    # limit 10
    # @new_articles = @new_articles.first(5)
    @archive_articles = @archive_articles.first(10)
    @feed_articles = @feed_articles.first(10)

    render "readwise/articles/index", locals: { archive_articles: @archive_articles, new_articles: @new_articles, feed_articles: @feed_articles }
  end

  def show
    @article = JSON.parse(File.read(Rails.root.join("db", "data", "readwise", "doc", "#{params[:id]}.json")))
  end
end
