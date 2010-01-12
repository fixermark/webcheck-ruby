require 'test/unit'
require 'uri'
require '_base'
require 'webcrawler'

class TC_Webcrawler < Test::Unit::TestCase
  def test_crawl_one
    checker=Webcrawler::new(uriFromTest("test_crawl_one/"))
    checker.crawlOne(uriFromTest("test_crawl_one/index.htm")) {|uri,req|
      assert_equal req.code,"200"
      [URI("success.htm")]
    }
    assert checker.toCrawl.include?(URI("success.htm"))
    assert checker.crawled.include?(uriFromTest("test_crawl_one/index.htm"))
  end

  def test_crawl_no_cycles
    checker=Webcrawler::new(uriFromTest("test_crawl_no_cycles/index.htm"))
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
  
  def test_crawl
    checker=Webcrawler::new(uriFromTest("test_crawl/index.htm"))
    my400s=[]
    my200s=[]
    checker.crawl {|uri,req|
      if req.code=="200"
        my200s << uri
      end
      if req.code=="404"
        my404s << uri
      end
      if uri==uriFromTest("test_crawl/index.htm")
        return [uriFromTest("test_crawl/exists.htm"),uriFromTest("test_crawl/should404.htm")]
      end
      return []
    }
    assert my200s.include?(uriFromTest("test_crawl/index.htm"))
    assert my200s.include?(uriFromTest("test_crawl/exists.htm"))
    assert my404s.include?(uriFromTest("test_crawl/should404.htm"))  
  end
end