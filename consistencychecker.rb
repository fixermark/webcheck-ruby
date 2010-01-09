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
   def check(uri,req)
    @checked[uri]=true
    if req.code=="404"
      @uris404 << uri
      return []
    end
    return []
   end
end