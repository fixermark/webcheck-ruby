require 'test/unit'
require '_base'
require 'webcheck'

class TC_Webcheck < Test::Unit::TestCase
  def test_kappa
    checker=Webcheck.new
    results = checker.check("http://foundation.kappachapter.org/index.html")
    checker.prettyPrint results
  end
end