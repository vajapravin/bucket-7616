require 'httpclient'
require 'json'

class String
  def as_json
    JSON.parse(self)
  end
end

module Score
  GENRES = [nil, 'other', 'CreateEvent', 'WatchEvent', 'PullRequestReviewCommentEvent', 'PushEvent', 'IssueCommentEvent', 'IssuesEvent']

  def fetch url
    clnt = HTTPClient.new
    resp = clnt.get_content(url)
    resp.as_json
  end

  def count commit_types
    commit_types.collect{|c| GENRES.include?(c) ? GENRES.index(c) : 1 }.inject(:+)
  end
end

class Github
  include Score

  HOST = "https://api.github.com"
  EVENTS = "/users/username/events/public"

  def events_score username
    endpoint = EVENTS.gsub(/username/, username)
    api = [HOST, endpoint].join
    json = fetch(api)
    p "#{username}'s github score is #{count(commit_types(json))}"
  end

  def commit_types json
    json.collect{|c| c['type']}
  end

end

g1 = Github.new
g1.events_score(ARGV[0])