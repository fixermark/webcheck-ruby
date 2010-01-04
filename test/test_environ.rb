require 'test/unit'
require '_base'

class TC_Environ < Test::Unit::TestCase
  def test_webbrick
    assert !is404("http://localhost:3001/tests/test_absolute_404/test.html")
    assert is404("http://localhost:3001/tests/test_absolute_404/does_not_exist.html")
  end
end