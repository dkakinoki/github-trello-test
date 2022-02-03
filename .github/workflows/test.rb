require 'net/http'
require 'uri'
require 'json'

base_url = "https://api.trello.com/1"
key_token_parmas = "key=#{ENV['KEY']}&token=#{ENV['TOKEN']}"

list_cards_path = "/lists/#{ENV['SOURCE_LIST_ID']}/cards"
list_cards_url = "#{base_url}#{list_cards_path}?#{key_token_parmas}"
res = Net::HTTP.get_response(URI.parse(list_cards_url))
cards = JSON.parse(res.body)
card_ids = cards.map{|card| card["id"]}

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
    card_update_path = "/cards/#{id}"
    uri = URI.parse("#{base_url}#{card_update_path}?#{key_token_parmas}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    puts ENV['DIST_LIST_ID']
    params = "idList=#{ENV['DIST_LIST_ID']}"
    headers = { "Accept" => "application/json" }
    http.put(uri, params, headers)
  end
end