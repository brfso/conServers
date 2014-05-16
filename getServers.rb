require 'rubygems'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'csv'

username = "#{ARGV[0]}"
password = "#{ARGV[1]}"
uri = URI("http://wiki.sec4you.com.br/display/SEC4YOU/%28SEC4YOU%29+Servidores")
req = Net::HTTP::Get.new(uri.request_uri)
req.basic_auth username, password

res = Net::HTTP.start(uri.hostname, uri.port) {|http|
  http.request(req)
}

doc = Nokogiri::HTML(res.body)
csv = CSV.open("/tmp/servers.csv", 'w',{:col_sep => ";", :quote_char => '\'', :force_quotes => false})

doc.xpath('//table/tbody/tr').each do |row|
  tarray = []
  row.xpath('td').each do |cell| cell
    tarray << cell.text
  end
  csv << tarray
end