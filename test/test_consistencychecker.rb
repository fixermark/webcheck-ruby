require 'test/unit'
require '_base'
require 'consistencychecker'
require 'linkfinder'
require 'net/http'

class TC_ConsistencyChecker < Test::Unit::TestCase
  def setup
    @linkfinder=Linkfinder.new
  end



  class Response
    attr_accessor :code, :body
    def initialize
      @header={}
    end	

    def [](key)
      a = @header[key.downcase] or return nil
      a.join(', ')
    end

    def []=(key,val)
      unless val
        @header.delete key.downcase
        return val
      end
      @header[key.downcase]=[val]
    end
  end
  
  def newResponse(params)
    response=Response.new
    response.code=params[:code] || "200"
    response.body=params[:body]
    response['content-type'] = params[:contentType] || 'text/html'
    return response
  end

  def test_404
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/nonexistant.htm")
    )
    res=newResponse :code=>'404'
    checker.check(uriFromTest("url_retriever/nonexistant.htm"),res)
    results=checker.results
    assert results[:uris404].include?(uriFromTest("url_retriever/nonexistant.htm"))
    assert_equal results[:uris200].empty?,true
    assert results[:checked].include?(uriFromTest("url_retriever/nonexistant.htm"))
  end
  
  def test_301
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/redirected.htm")
    )
    res=newResponse :code=>'301'
    checker.check(uriFromTest("url_retriever/redirected.htm"),res)
    results=checker.results
    assert_equal results[:urisUnknown][0][:code], "301"    
    assert_equal results[:urisUnknown][0][:uri], uriFromTest("url_retriever/redirected.htm")
    assert results[:checked].include?(uriFromTest("url_retriever/redirected.htm"))
  end
  
  def test_200
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/test.htm")
    )
    res=newResponse :body=> <<EOF
<html>
<head>
<title>Consistency checker -- 200 result code test</title>
</head>
<body>
<p>This is a test of the consistency checker.</p>
<a href="http://localhost:3001/tests/url_retriever/testA.htm">Test 1</a>
</body>
</html>
EOF
    
    links=checker.check(uriFromTest("url_retriever/test.htm"),res)
    results=checker.results
    assert_equal results[:uris404].empty?,true
    assert results[:uris200].include?(uriFromTest("url_retriever/test.htm"))
    assert results[:checked].include?(uriFromTest("url_retriever/test.htm"))
    assert links.include?(uriFromTest("url_retriever/testA.htm"))
  end

  def test_absolute_url
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/test.htm")
    )
    res=newResponse :body=> <<EOF
<html>
<head>
<title>Consistency checker -- 200 result code test</title>
</head>
<body>
<p>This is a test of the consistency checker.</p>
<a href="testB.htm">Test 2</a>
<a href="mailto:test@example.com">E-mail URL test</a>
</body>
</html>
EOF
    
    links=checker.check(uriFromTest("url_retriever/test.htm"),res)
    assert links.include?(uriFromTest("url_retriever/testB.htm"))
  end

  # Resources from foreign links are requested to verify they do not 404,
  # but they are not crawled
  
  def test_outbound_link
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/test.htm")
    )
    res=newResponse :body=> <<EOF
<html>
<head>
<title>Consistency checker -- foreign domain test</title>
</head>
<body>
<p>This is an example.com domain.</p>
<a href="testB.htm">Test 2</a>
</body>
</html>
EOF
    links=checker.check(URI("http://www.example.com"),res)
    assert links.empty?
  end

  def test_non_http
    checker=ConsistencyChecker.new(
      @linkfinder,
      URI("http://example.com/test.htm")
    )
    res=newResponse :body=> <<EOF
<html>
<head>
<title>Consistency checker -- mailto link test</title>
</head>
<body>
<p>This is an example.com domain.</p>
<a href="mailto:test@example.com">e-mail me</a>
</body>
</html>
EOF
    links=checker.check(URI("http://example.com/index.htm"),res)
    assert links.empty?
    assert_equal URI("mailto:test@example.com"), checker.results[:urisNonHTTP][0] 
  end

  def test_cycle
    checker=ConsistencyChecker.new(
      @linkfinder,
      URI("http://example.com/docA.htm")
    )
    res1=newResponse :body=> <<EOF
<html>
<head>
<title>Consistency checker -- cycle link test -- document A</title>
</head>
<body>
<p>This is an example.com domain.</p>
<a href="http://example.com/docB.htm">To doc B</a>
</body>
</html>
EOF
    res2=newResponse :body=> <<EOF
<html>
<head>
<title>Consistency checker -- cycle link test -- document A</title>
</head>
<body>
<p>This is an example.com domain.</p>
<a href="http://example.com/docA.htm">To doc A</a>
</body>
</html>
EOF
    links=checker.check(URI("http://example.com/docA.htm"),res1)
    links2=checker.check(URI("http://example.com/docB.htm"),res2)
    assert links.include?(URI("http://example.com/docB.htm"))
    assert links2.empty?
  end

  def test_image
    checker=ConsistencyChecker.new(
      @linkfinder,
      URI("http://example.com/img.gif")
    )
    res=newResponse :contentType=>'image/gif',
    :body => <<EOF
<html>
<head><title>Test - not HTML at all!</title></head>
<body>
<a href="http://example.com/we_should_not_see_this.html">Shouldn't see this!</a>
</body>
</html>
EOF

    links=checker.check(URI("http://example.com/img.gif"),res)
    assert links.empty?
    assert checker.results[:checked].include?(URI("http://example.com/img.gif"))
  end
end
