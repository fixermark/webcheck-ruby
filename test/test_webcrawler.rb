require 'test/unit'
require 'uri'
require '_base'
require 'webcrawler'
require 'nokogiri'

class TC_Webcrawler < Test::Unit::TestCase
  def test_crawl_one
    checker=Webcrawler::new(uriFromTest("test_crawl_one/").to_s)
    checker.crawlOne(uriFromTest("test_crawl_one/index.htm")) {|uri,req|
      assert_equal req.code,"200"
      [URI("success.htm")]
    }
    assert checker.toCrawl.include?(URI("success.htm"))
    assert checker.crawled.include?(uriFromTest("test_crawl_one/index.htm"))
  end

  def test_crawl_no_cycles
    checker=Webcrawler::new(uriFromTest("test_crawl_no_cycles/index.htm").to_s)
    checker.crawlNext {|uri,req|
      [uriFromTest("test_crawl_no_cycles/testA.htm")]
    }
    checker.crawlNext {|uri,req|
      assert_equal uri,uriFromTest("test_crawl_no_cycles/testA.htm")
      [uriFromTest("test_crawl_no_cycles/testB.htm")]
    }
    checker.crawlNext {|uri,req|
      assert_equal uri,uriFromTest("test_crawl_no_cycles/testB.htm")
      [uriFromTest("test_crawl_no_cycles/testA.htm")]
    }
    assert checker.toCrawl.empty?
  end
  
  #def test_crawl
  #  checker=Webcrawler::new("http://localhost:3001/tests/test_crawl/index.htm")
  #  checker.crawl()
  #  assert checker.pages200.include?(uriFromTest("test_crawl/index.htm"))
  #  assert checker.pages200.include?(uriFromTest("test_crawl/exists.htm"))
  #  assert checker.pages404.include?(uriFromTest("test_crawl/should404.htm"))
  #end
end