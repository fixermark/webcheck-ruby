require 'test/unit'
require 'uri'
require '_base'
require 'webcrawler'
require 'nokogiri'

class TC_Webcrawler < Test::Unit::TestCase

  def test_crawl_one
    checker=Webcrawler::new(uriFromTest("test_crawl_one/").to_s)
    checker.crawlOne(uriFromTest("test_crawl_one/index.htm")) {|req|
      assert_equal req.code,"200"
      [URI("success.htm")]
    }
    assert checker.toCrawl.include?(URI("success.htm"))
    assert checker.crawled.include?(uriFromTest("test_crawl_one/index.htm"))
  end
  
  #def test_crawl
  #  checker=Webcrawler::new("http://localhost:3001/tests/test_crawl/index.htm")
  #  checker.crawl()
  #  assert checker.pages200.include?(uriFromTest("test_crawl/index.htm"))
  #  assert checker.pages200.include?(uriFromTest("test_crawl/exists.htm"))
  #  assert checker.pages404.include?(uriFromTest("test_crawl/should404.htm"))
  #end
  
  #def test_crawl_no_cycles
  #  # TODO: Test that validates mutually-referential pages don't back-crawl
  #  checker=Webcrawler::new(uriFromTest("test_crawl_no_cycles/index.htm").to_s)
  #  checker.crawlNext
  #  assert checker.toCrawl.include?(uriFromTest("test_crawl_no_cycles/rosencrantz.htm"))
  #  checker.crawlNext
  #  assert checker.toCrawl.include?(uriFromTest("test_crawl_no_cycles/guildenstern.htm"))
  #  checker.crawlNext
  #  assert checker.crawled.include?(uriFromTest("test_crawl_no_cycles/guildenstern.htm"))
  #  assert checker.pages404.empty?
  #  assert checker.toCrawl.empty?
  #end
  
  #def test_crawl_no_outbound
  #  checker=Webcrawler::new(uriFromTest("test_crawl_no_outbound/index.htm").to_s)
  #  checker.crawlNext
  #  assert checker.pages200.include?(uriFromTest("test_crawl_no_outbound/index.htm"))
  #  assert checker.toCrawl.empty?    
  #end
end