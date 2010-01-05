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

  def test_convert_rel_abs
    relativeURLs=[
      "http://google.com",
      "target1.htm",
      "../target2.htm",
      "d2/target3.htm",
      "/target4.htm",
      "mailto:me@example.com"
    ]
    absoluteURLs=Webcheck::convertToAbsolute(
      relativeURLs,
      URI("http://example.com/d1/base.htm")
    )
    assert absoluteURLs.include?(URI("http://google.com"))
    assert absoluteURLs.include?(URI("http://example.com/d1/target1.htm"))
    assert absoluteURLs.include?(URI("http://example.com/target2.htm"))
    assert absoluteURLs.include?(URI("http://example.com/d1/d2/target3.htm"))
    assert absoluteURLs.include?(URI("http://example.com/target4.htm"))
    assert absoluteURLs.include?(URI("mailto:me@example.com"))
  
	absoluteURLs=Webcheck::convertToAbsolute(
	  relativeURLs,
	  URI("http://example.com")
	)
	assert absoluteURLs.include?(URI("http://google.com"))
	assert absoluteURLs.include?(URI("http://example.com/target1.htm"))
	assert absoluteURLs.include?(URI("http://example.com/../target2.htm"))
	assert absoluteURLs.include?(URI("http://example.com/d2/target3.htm"))
	assert absoluteURLs.include?(URI("http://example.com/target4.htm"))
	assert absoluteURLs.include?(URI("mailto:me@example.com"))
  end
	
  def test_crawl_one
    checker=Webcheck::new("http://localhost:3001/tests/test_crawl_one/")
    checker.crawlOne(URI("http://localhost:3001/tests/test_crawl_one/index.htm"))
    assert checker.crawled.include?(URI("http://localhost:3001/tests/test_crawl_one/index.htm"))
    assert checker.toCrawl.include?(URI("http://localhost:3001/tests/test_crawl_one/exists.htm"))
    assert checker.toCrawl.include?(URI("http://localhost:3001/tests/test_crawl_one/should404.htm"))
    assert checker.pages404.empty?
    assert checker.pages200.include?(URI("http://localhost:3001/tests/test_crawl_one/index.htm"))   
  end
  
  def test_crawl
    checker=Webcheck::new("http://localhost:3001/tests/test_crawl/index.htm")
    checker.crawl()
    assert checker.pages200.include?(URI("http://localhost:3001/tests/test_crawl/index.htm"))
    assert checker.pages200.include?(URI("http://localhost:3001/tests/test_crawl/exists.htm"))
    assert checker.pages404.include?(URI("http://localhost:3001/tests/test_crawl/should404.htm"))
  end
end