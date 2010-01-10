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
    
    assert checker.uris404.include?(uriFromTest("url_retriever/nonexistant.htm"))
    assert_equal checker.uris200.empty?,true
    assert checker.checked.include?(uriFromTest("url_retriever/nonexistant.htm"))
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
    
    assert_equal checker.urisUnknown[0][:code], "301"    
    assert_equal checker.urisUnknown[0][:uri], uriFromTest("url_retriever/redirected.htm")
    assert checker.checked.include?(uriFromTest("url_retriever/redirected.htm"))
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
    
    result=checker.check(uriFromTest("url_retriever/test.htm"),res)
    assert_equal checker.uris404.empty?,true
    assert checker.uris200.include?(uriFromTest("url_retriever/test.htm"))
    assert checker.checked.include?(uriFromTest("url_retriever/test.htm"))
    assert result.include?(uriFromTest("url_retriever/testA.htm"))
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
    
    result=checker.check(uriFromTest("url_retriever/test.htm"),res)
    assert result.include?(uriFromTest("url_retriever/testB.htm"))
    assert result.include?(URI("mailto:test@example.com"))
  end
end
