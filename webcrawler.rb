require 'net/http'
require 'uri' 
require 'nokogiri'

# Opens and reads pages via HTTP. The pages to read are driven by a provided
# block, which serves as the logic for the crawl. The crawler does not track
# recursive crawls; the provided block must be careful to avoid requesting
# the same page repeatedly, or a crawl could become stuck on an infinite
# cycle
# 
# == About the control block
#
# Most of the functions take a block that serves as the control block.
# The block provided should take as arguments a URI and an HTTPResponse, 
# and should yield a list of URIs to process in subsequent steps of the crawl.
#
# Usage example:
#
#   require 'linkfinder'
#   require 'consistencychecker'
#   require 'uri'
#
#   myURI=URI("http://example.com")
#
#   crawler=Webcrawler.new(myURI)
#   checker=ConsistencyChecker.new(linkfinder,myURI)
#   crawler.crawl{|uri,res|
#     checker.check(uri,res)
#   }

class Webcrawler

  # Open a page and extract URLs from the page
  # [uri] The URL to open (as an absolute URI)
  # returns:: the HTTP response
  def retrievePage(uri)
    print "Retrieving ",uri,"\n"
    Net::HTTP::start(uri.host,uri.port) {|http|
      path=uri.path
      if path==nil or path==""
        path="/"
      end
      http.get(path)
    }
  end

  attr_reader :crawled,:toCrawl
  
  def initialize(startURI)
    @crawled = {}
    @toCrawl = []
    @startURI=startURI
    @toCrawl << @startURI
  end

  # crawl a single page, updating the internal state 
  # of which pages have been seen and which have not
  #
  # [uri] The URI to crawl
  # [block] the control block
  def crawlOne(uri)
    @crawled[uri]=true
    req = retrievePage(uri)
    newURIs = yield(uri,req)
    newURIs.each{|link|
      if @crawled[link] == nil
        @toCrawl << link
      end
    }
  end
  
  # crawl the next page that hasn't
  # been crawled
  #
  # [blk] The control block
  #
  # return: true if crawling should continue, false otherwise
  def crawlNext(&blk)
    if @toCrawl.empty?
      return false
    end
    crawlThis=@toCrawl.pop()
    crawlOne(crawlThis,&blk)
    return true
  end
  
  # crawl all pages not yet crawled,
  # stopping when we run out
  #
  # [blk] The control block
  def crawl(&blk)
    while crawlNext(&blk)
    end
  end
end