class ReadwiseController < ApplicationController
  def index
    # json_files = Dir.glob(Rails.root.join('db', 'data', 'readwise', 'doc', '*.json'))
    # @articles = json_files.map { |file| JSON.parse(File.read(file)) }
    # @articles.sort_by! { |article| article['last_moved_at'] }.reverse!
    # render 'readwise/index', locals: { articles: @articles }
    # redirect_to readwise_articles_path

  end

  def doc
    @data = JSON.parse(File.read(Rails.root.join('db', 'data', 'readwise', 'doc', "#{params[:id]}.json")))
    render 'readwise/doc', locals: { data: @data }
  end

  def show
    @readwise = Readwise.find(params[:id])
    render json: @readwise
  end

end
