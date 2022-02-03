require 'net/http'
require 'uri'
url = "https://api.trello.com/1/search?key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_TOKEN']}&query=test&modelTypes=cards&card_fields=url"
print Net::HTTP.get(URI.parse(url))