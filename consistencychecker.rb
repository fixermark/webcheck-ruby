 # Basic consistency checker---finds 404s and 200s
 
class ConsistencyChecker
  attr_reader :uris404,:uris200,:urisUnknown,:checked

   def initialize(linkfinder,baseURI)
    @uris404=[]
    @uris200=[]
    @urisUnknown=[]
    @checked={}
    @linkfinder=linkfinder
    @baseURI=baseURI
   end
   def check(uri,res)
    @checked[uri]=true
    if res.code=="404"
      @uris404 << uri
      return []
    elsif res.code=="200"
      @uris200 << uri
      if uri.host != @baseURI.host
      	 return []
      end
      links = @linkfinder.getLinks(res.body)
      # TODO: relative to absolute
      # TODO: filter outbound?
      links=@linkfinder.convertToAbsolute(links,uri)
      result=[]
      links.each {|link|  
        result << link
      }
      return result
    else
      @urisUnknown << {:code => res.code, :uri => uri}
    end
    return []
   end
end