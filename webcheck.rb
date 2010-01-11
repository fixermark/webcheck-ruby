# Full web checker - given an origin point in a server, crawls the server
#      to validate aspects of the site (such as 404s)

require 'webcrawler'
require 'linkfinder'
require 'consistencychecker'
require 'uri'

class Webcheck
  def check(uri)
    if uri.class ~= URI
       uri=URI(uri)
    end
    crawler=Webcrawler.new(uri)
    linkfinder=Linkfinder.new
    checker=Consistencychecker.new(linkfinder,uri)
    crawler.crawl {|uri,res|
      checker.check(uri,res)
    }
    checker.results
end