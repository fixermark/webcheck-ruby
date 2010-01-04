require 'test/unit'
require 'uri'
require '_base'
require 'webcheck'

class TC_Webcheck < Test::Unit::TestCase
  
  TestHTML=
<<EOF
  <html>
  <head>
  <title>URL extraction test case</title>
  </head>
  <body>
  Here comes some text!
  <a href="http://example.com/test.htm">Example 1</a><br/>
  <a href="test2.htm">Local example 1</a><br/>
  <a href="/index.htm">Base example 1</a><br/>
  <a href="mailto:nobody@example.com">Mail link example 1</a><br/>
  </body>
  </html>
EOF

  def test_url_extractor
    links = Webcheck::getLinks(TestHTML)
    assert links.include?("http://example.com/test.htm")
    assert links.include?("test2.htm")
    assert links.include?("/index.htm")
    assert links.include?("mailto:nobody@example.com")
  end
  
  def test_url_retriever_200
    code,links = Webcheck::getLinksFromPage(URI("http://localhost:3001/tests/url_retriever/test.htm"))
    assert_equal "200",code
    assert links.include?("one.htm")
    assert links.include?("http://example.com/two.htm")
    assert links.include?("mailto:test@example.com")
  end

  def test_url_retriever_404
    code,links = Webcheck::getLinksFromPage(URI("http://localhost:3001/tests/url_retriever/nonexistant.htm"))
    assert_equal "404",code
    assert_nil links
  end
end