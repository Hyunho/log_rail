require "net/http"
require "json"
require "fileutils"
require "rails"

BASE_URL = "https://telcoware.atlassian.net"
EMAIL = ENV["ATLASSIAN_EMAIL"]
API_TOKEN = ENV["ATLASSIAN_API_TOKEN"]

START_DATE = "2025-09-25"
END_DATE = "2025-10-01"

def fetch_issue(issue_key)
  search_url = "#{BASE_URL}/rest/api/3/issue/#{issue_key}"
  response = make_request(URI(search_url))
  JSON.parse(response.body)
end

def fetch_worklog_issues(start_date, end_date)
  jql_work_query = "(project = \"Telcobase Support\" OR project = \"Telcobase 유지보수\" OR project = TBMON) AND worklogDate >= \"#{start_date}\" AND worklogDate < \"#{end_date}\""
  search_url = "#{BASE_URL}/rest/api/3/search/jql"
  params = {
    jql: jql_work_query,
    fields: [ "summary", "key", "issuetype", "worklog" ],
    maxResults: 100  # 필요한 경우 결과 수 조정
  }
  response = make_request(URI(search_url), params)

  issues_data = JSON.parse(response.body)

  issues = []
  issues_data["issues"].each do |issue|
    issue_key = issue["key"]
    worklog_url = "#{BASE_URL}/rest/api/3/issue/#{issue_key}/worklog"
    worklog_response = make_request(URI(worklog_url))
    worklogs_data = JSON.parse(worklog_response.body)

    total_time_spent = 0
    worklogs_data["worklogs"].each do |worklog|
      if worklog["started"] >= start_date && worklog["started"] < end_date
        total_time_spent += worklog["timeSpentSeconds"]
      end
    end
    puts JSON.pretty_generate(issue) if ENV["DEBUG_MODE"] == "true"
    issues << {
      key: issue["key"],
      summary: issue["fields"]["summary"],
      total_time_spent: total_time_spent.to_f / 60 / 60,
      start_date: start_date,
      end_date: end_date,
      issue_type: issue["fields"]["issuetype"]["name"]
    }
  end
  issues
end
private

def make_request(uri, params = {})
  # Add parameters to URI if they exist
  if params.any?
    uri.query = URI.encode_www_form(params)
  end

  req = Net::HTTP::Get.new(uri)
  req.basic_auth(EMAIL, API_TOKEN)
  req["Accept"] = "application/json"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    response = http.request(req)

    case response.code.to_i
    when 200..299
      response
    when 401
      raise "인증 실패: API 토큰을 확인하세요"
    when 403
      raise "권한 없음: 해당 리소스에 접근할 수 없습니다"
    when 404
      raise "리소스를 찾을 수 없습니다"
    when 429
      raise "요청 한도 초과: 잠시 후 다시 시도하세요"
    else
      error_body = response.body.force_encoding("UTF-8") rescue response.body
      raise "API 에러 (#{response.code}): #{error_body}"
    end
  end
end

issues = fetch_worklog_issues(START_DATE, END_DATE)
# puts JSON.pretty_generate(issues)

jira_data_dir = Rails.root.join("db", "data", "jira")
FileUtils.mkdir_p(jira_data_dir)
File.write(jira_data_dir.join("issues.json"), JSON.pretty_generate(issues))
