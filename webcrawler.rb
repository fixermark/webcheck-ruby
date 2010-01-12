require 'net/http'
require 'uri' 
require 'nokogiri'

class Webcrawler

  # Open a page and extract URLs from the page
  # * uri - The URL to open (as a URI)
  # returns: the HTTP request
  def retrievePage(uri)
    Net::HTTP::start(uri.host,uri.port) {|http|
      path=uri.path
      if path==nil
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

  # crawl a single page, updating the internal notions 
  # of which pages have been seen and which have not
  #
  # * uri - The URI to crawl
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
  # return: true if crawling should
  # continue, false otherwise
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
  def crawl(&blk)
    while crawlNext(&blk)
    end
  end
end