require 'net/http'
require 'open-uri'
$: << "gems/gems/nokogiri-1.4.1-x86-mswin32/lib"

require 'nokogiri'

doc = Nokogiri::HTML(
    #open('http://foundation.kappachapter.org/index.html')
)

doc.css('a').each do |link|
  puts link['href']
end

