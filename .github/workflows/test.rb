require 'net/http'
require 'uri'
print Net::HTTP.get(URI.parse('https://jsonplaceholder.typicode.com/todos/1'))
print ENV["TRELLO_TOKEN"]