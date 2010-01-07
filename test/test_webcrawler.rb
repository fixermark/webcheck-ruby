require 'test/unit'
require 'uri'
require '_base'
require 'webcrawler'

class TC_Webcrawler < Test::Unit::TestCase
  
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
  def uriFromTest(path)
    URI("http://localhost:3001/tests/"+path)
  end

  def test_url_extractor
    links = Webcrawler::getLinks(TestHTML)
    assert links.include?("http://example.com/test.htm")
    assert links.include?("test2.htm")
    assert links.include?("/index.htm")
    assert links.include?("mailto:nobody@example.com")
  end
  
  def test_url_retriever_200
    code,links = Webcrawler::getLinksFromPage(URI("http://localhost:3001/tests/url_retriever/test.htm"))
    assert_equal "200",code
    assert links.include?("one.htm")
    assert links.include?("http://example.com/two.htm")
    assert links.include?("mailto:test@example.com")
  end

  def test_url_retriever_404
    code,links = Webcrawler::getLinksFromPage(URI("http://localhost:3001/tests/url_retriever/nonexistant.htm"))
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
    absoluteURLs=Webcrawler::convertToAbsolute(
      relativeURLs,
      URI("http://example.com/d1/base.htm")
    )
    assert absoluteURLs.include?(URI("http://google.com"))
    assert absoluteURLs.include?(URI("http://example.com/d1/target1.htm"))
    assert absoluteURLs.include?(URI("http://example.com/target2.htm"))
    assert absoluteURLs.include?(URI("http://example.com/d1/d2/target3.htm"))
    assert absoluteURLs.include?(URI("http://example.com/target4.htm"))
    assert absoluteURLs.include?(URI("mailto:me@example.com"))
  
	absoluteURLs=Webcrawler::convertToAbsolute(
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
    checker=Webcrawler::new(uriFromTest("test_crawl_one/").to_s)
    checker.crawlOne(uriFromTest("test_crawl_one/index.htm"))
    assert checker.crawled.include?(uriFromTest("test_crawl_one/index.htm"))
    assert checker.toCrawl.include?(uriFromTest("test_crawl_one/exists.htm"))
    assert checker.toCrawl.include?(uriFromTest("test_crawl_one/should404.htm"))
    assert checker.pages404.empty?
    assert checker.pages200.include?(uriFromTest("test_crawl_one/index.htm"))   
  end
  
  def test_crawl
    checker=Webcrawler::new("http://localhost:3001/tests/test_crawl/index.htm")
    checker.crawl()
    assert checker.pages200.include?(uriFromTest("test_crawl/index.htm"))
    assert checker.pages200.include?(uriFromTest("test_crawl/exists.htm"))
    assert checker.pages404.include?(uriFromTest("test_crawl/should404.htm"))
  end
  
  def test_crawl_no_cycles
    # TODO: Test that validates mutually-referential pages don't back-crawl
    checker=Webcrawler::new(uriFromTest("test_crawl_no_cycles/index.htm").to_s)
    checker.crawlNext
    assert checker.toCrawl.include?(uriFromTest("test_crawl_no_cycles/rosencrantz.htm"))
    checker.crawlNext
    assert checker.toCrawl.include?(uriFromTest("test_crawl_no_cycles/guildenstern.htm"))
    checker.crawlNext
    assert checker.crawled.include?(uriFromTest("test_crawl_no_cycles/guildenstern.htm"))
    assert checker.pages404.empty?
    assert checker.toCrawl.empty?
  end
  
  def test_crawl_no_outbound
    checker=Webcrawler::new(uriFromTest("test_crawl_no_outbound/index.htm").to_s)
    checker.crawlNext
    assert checker.pages200.include?(uriFromTest("test_crawl_no_outbound/index.htm"))
    assert checker.toCrawl.empty?    
  end
end