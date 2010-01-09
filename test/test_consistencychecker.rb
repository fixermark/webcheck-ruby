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
end
