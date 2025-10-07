class JiraController < ApplicationController
  def index
    # @start_date = START_DATE
    # @end_date = END_DATE
    # @issues = JiraIssue.all
    @issues = JSON.parse(File.read(Rails.root.join("db", "data", "jira", "issues.json")))
    # @issues = JiraIssuesCache.new(start_date: @start_date, end_date: @end_date).fetch_worklog_issues
    @issues = @issues.sort_by { |issue| issue["total_time_spent"] }.reverse
    # @issues = @issues.select { |issue| issue["total_time_spent"] > 0 }
    puts JSON.pretty_generate(@issues)
    # read issues.json
  end

  def update_cache
    JiraIssue.delete_all
    @start_date = START_DATE
    @end_date = END_DATE
    JiraIssuesCache.new(start_date: @start_date, end_date: @end_date).update_cache
    redirect_to action: :index, notice: "Cache updated"
  end
end
