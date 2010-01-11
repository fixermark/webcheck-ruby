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
  end
  
  def test_404
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/nonexistant.htm")
    )
    res=Response.new
    res.code="404"
    res.body=nil
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
    res=Response.new
    res.code="301"
    res.body=nil
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
    res=Response.new
    res.code="200"
    res.body=<<EOF
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
    res=Response.new
    res.code="200"
    res.body=<<EOF
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
    assert links.include?(URI("mailto:test@example.com"))
  end

  # Resources from foreign links are requested to verify they do not 404,
  # but they are not crawled
  
  def test_outbound_link
    checker=ConsistencyChecker.new(
      @linkfinder,
      uriFromTest("url_retriever/test.htm")
    )
    res=Response.new
    res.code="200"
    res.body=<<EOF
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
end
