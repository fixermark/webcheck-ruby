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
    end
    if res.code=="200"
      @uris200 << uri
      links = @linkfinder.getLinks(res.body)
      # TODO: relative to absolute
      # TODO: filter outbound?
      result=[]
      links.each {|link|
        result << URI(link)
      }
      return result
    end
    return []
   end
end