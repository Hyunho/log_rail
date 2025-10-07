
server:
	bin/rails server

gen: jira
	rails runner script/gen.rb

jira:
	rails runner script/get_jira.rb