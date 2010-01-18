require 'nokogiri'
require 'uri'

# Locates all of the hyperlinks in the body of an HTML document
class Linkfinder
  
  # Retrieve an array of all the links from the specified HTML document. The
  # links may be either relative or absolute.
  # 
  def getLinks(html)
    doc = Nokogiri::HTML(html)
    result = Array.new
    doc.css('a').each do |link|
      result << link[:href]
    end
    result
  end

  # convert relative URLs(strings) to absolute URLs
  # (URIs), filling in information from the base URI
  # as needed
  #
  # [urls] array of string urls
  # [baseURI] the URI to use as the base for relative resolution
  # return:: array of absolute URIs
  def convertToAbsolute(urls,baseURI)
    result=[]
    urls.each {|url|
      newURI=URI(url)
      if newURI.relative?
        if url[0]=="/"[0]
	  newURI=URI("http://" + baseURI.host + url)
        else
	  newURI=baseURI + newURI
        end
      end
      result << newURI
    }
    return result
  end

  # True if uri is in the same domain as domainURI
  def inDomain?(uri,domainURI)
      uri.host == domainURI.host
  end
end