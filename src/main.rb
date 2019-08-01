require 'faraday'
require 'json'

account_id = ENV['NEW_RELIC_ACCOUNT_ID']
query = ENV['INSIGHTS_QUERY']
headers =  { 
  'X-Query-Key' => ENV['NEW_RELIC_INSIGHTS_QUERY_KEY'],
  'Accept' => 'application/json'
}
url = "https://insights-api.newrelic.com/v1/accounts/#{account_id}/query?nrql=#{query}"

response = Faraday.get(url, nil, headers)
puts response.body
