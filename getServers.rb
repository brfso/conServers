require 'rubygems'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'csv'
require 'openssl'

username = "#{ARGV[0]}"
password = "#{ARGV[1]}"

uri = URI("#{ARGV[2]}")

res = Net::HTTP.start(uri.host, uri.port,
  :use_ssl => uri.scheme == 'https',
  :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

  request = Net::HTTP::Get.new uri.request_uri
  request.basic_auth  username, password
  http.request(request)
end


doc = Nokogiri::HTML(res.body)
csv = CSV.open("/tmp/servers.csv", 'w',{:col_sep => ";", :quote_char => '\'', :force_quotes => false})

doc.xpath('//table/tbody/tr').each do |row|
  tarray = []
  row.xpath('td').each do |cell| cell
    tarray << cell.text
  end
  csv << tarray
end
