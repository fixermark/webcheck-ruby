 # Basic consistency checker---finds 404s and 200s
 
class ConsistencyChecker
  attr_reader :results

   def initialize(linkfinder,baseURI)
    @results={
      :uris404=>[],
      :uris200=>[],
      :urisUnknown=>[],
      :checked=>{}
    }
    @linkfinder=linkfinder
    @baseURI=baseURI
   end
   def check(uri,res)
    @results[:checked][uri]=true
    if res.code=="404"
      @results[:uris404] << uri
      return []
    elsif res.code=="200"
      @results[:uris200] << uri
      if uri.host != @baseURI.host
      	 return []
      end
      links = @linkfinder.getLinks(res.body)
      # TODO: relative to absolute
      # TODO: filter outbound?
      links=@linkfinder.convertToAbsolute(links,uri)
      returnedLinks=[]
      links.each {|link|  
        returnedLinks << link
      }
      return returnedLinks
    else
      results[:urisUnknown] << {:code => res.code, :uri => uri}
    end
    return []
   end
end