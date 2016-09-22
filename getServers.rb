require 'rubygems'
require 'nokogiri'
require 'uri'
require 'net/https'
require 'csv'

def fetch(uri_str, username, password, limit = 10)
  # You should choose a better exception.
  raise ArgumentError, 'too many HTTP redirects' if limit == 0

  uri = URI(uri_str)
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth username, password

  response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => (uri.scheme == 'https')) {|http|
    http.request(req)
  }

  case response
  when Net::HTTPSuccess then
    response
  when Net::HTTPRedirection then
    location = response['location']
    warn "Redirected to #{location}"
    fetch(location, username, password, limit - 1)
  else
    response.value
  end
end

def loadServers(body)
    doc = Nokogiri::HTML(body)
    csv = CSV.open("/tmp/servers.csv", 'w',{:col_sep => ";", :quote_char => '\'', :force_quotes => false})
    
    doc.xpath('//table/tbody/tr').each do |row|
        tarray = []
        row.xpath('td').each do |cell| cell
                tarray << cell.text
        end
        csv << tarray
    end
end 

username = "#{ARGV[0]}"
password = "#{ARGV[1]}"
url = "#{ARGV[2]}"

res = fetch(url, username, password)

code = res.code

if code == "200" then
   loadServers(res.body)
else
   puts "Wiki is not available. Return code '#{code}'"
end

