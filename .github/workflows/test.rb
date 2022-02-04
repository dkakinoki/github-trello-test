require 'net/http'
require 'uri'
require 'json'

base_url = "https://api.trello.com/1"
key_token_parmas = "key=#{ENV['KEY']}&token=#{ENV['TOKEN']}"

puts "get card ids"
list_cards_path = "/lists/#{ENV['SOURCE_LIST_ID']}/cards"
list_cards_url = "#{base_url}#{list_cards_path}?#{key_token_parmas}"
res = Net::HTTP.get_response(URI.parse(list_cards_url))
if res.code == '200'
  cards = JSON.parse(res.body)
  card_ids = cards.map{|card| card["id"]}
else
  puts "code: #{res.code}, body:#{res.body}. message: #{res.message}"
  return
end

puts "check github url"
card_ids.each do |id|
  card_attachments_path = "/cards/#{id}/attachments"
  card_attachment_url = "#{base_url}#{card_attachments_path}?#{key_token_parmas}"
  res = Net::HTTP.get_response(URI.parse(card_attachment_url))
  attachments = JSON.parse(res.body)
  attachment = attachments.find{|attachment|
    attachment["isUpload"] == false && attachment["url"].match(/https:\/\/git/)
  }
  next if attachment == nil
  if attachment["url"] == ENV['PULL_REQUEST_URL']
    puts "move list"
    card_update_path = "/cards/#{id}"
    uri = URI.parse("#{base_url}#{card_update_path}?#{key_token_parmas}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    params = "idList=#{ENV['DEST_LIST_ID']}"
    headers = { "Accept" => "application/json" }
    http.put(uri, params, headers)
    break
  end
end