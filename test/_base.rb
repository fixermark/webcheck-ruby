require 'net/http'
require 'uri'
def is404(urlString)
  url=URI.parse(urlString)
  req = Net::HTTP::start(url.host,url.port) {|http|
    http.get(url.path)
  }
  return req.code == "404"
end

def uriFromTest(path)
  URI("http://localhost:3001/tests/"+path)
end
