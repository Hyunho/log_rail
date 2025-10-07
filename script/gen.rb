require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'fileutils'
require 'erb'
require 'time'

TOKEN = 'Xh5XuViEGV2vGomFcf4xcMeAcBNgneIK3ohuNs7R1rmk29IoxB'

def fetch_reader_document_list_api(updated_after: nil, location: nil)
    # full_data = []
    # next_page_cursor = nil

    #   loop do
    params = {}
    # params['pageCursor'] = next_page_cursor if next_page_cursor
    # params['updatedAfter'] = updated_after if updated_after
    # params['location'] = location if location
    params['category'] = 'article'
    # params['location'] = 'archive'
    # params['location'] = 'new'
    # params['location'] = 'feed'

    uri = URI("https://readwise.io/api/v3/list/")
    uri.query = URI.encode_www_form(params) unless params.empty?

    # puts "Making export api request with params #{params}..."

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  # Python 코드의 verify=False 대응

    request = Net::HTTP::Get.new(uri.request_uri, { "Authorization" => "Token #{TOKEN}" })

    response = http.request(request)
    data = JSON.parse(response.body)

  # full_data.concat(data['results'])
  # next_page_cursor = data['nextPageCursor']
  # break unless next_page_cursor
  #   end

  data['results'] if data['results']
  # full_data
end

# Get all of a user's documents from all time
all_data = fetch_reader_document_list_api

# clear output folder
readwise_data_dir = Rails.root.join("db", "data", "readwise")

# FileUtils.rm_rf(readwise_html_dir)
# FileUtils.mkdir_p(readwise_html_dir)
FileUtils.rm_rf(readwise_data_dir)
FileUtils.mkdir_p(readwise_data_dir)

for data in all_data
  # published_date = data['published_date'] ? Time.at(data['published_date'] / 1000).getlocal("+09:00").strftime('%Y-%m-%d') : 'No Date'
  published_date = data['published_date'] ? Time.at(data['published_date'] / 1000).strftime('%Y-%m-%d') : 'No Date'
  data['published_date'] = published_date
end

# sort all_data by published_date desc
all_data.sort_by! { |data| data['published_date'] }.reverse!

# list data using template/index.html with all_data
# template = File.read('script/template/index.html.erb')
# erb = ERB.new(template)
# File.write(readwise_html_dir.join("index.html"), erb.result_with_hash(all_data: all_data))

# make docs folder
# FileUtils.mkdir_p(readwise_html_dir.join("docs"))

FileUtils.rm_rf(readwise_data_dir.join("doc"))
FileUtils.mkdir_p(readwise_data_dir.join("doc"))

for data in all_data
  # File.write(readwise_html_dir.join("docs", "#{data['id']}.html"), ERB.new(File.read('script/template/doc.html.erb')).result_with_hash(data: data))
  File.write(readwise_data_dir.join("doc", "#{data['id']}.json"), JSON.pretty_generate(data))
end
