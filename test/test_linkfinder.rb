require 'test/unit'
require '_base'
require 'linkfinder'

class TC_Linkfinder < Test::Unit::TestCase
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
  def setup
    @linkfinder=Linkfinder.new
  end

  def test_url_extractor
    links = @linkfinder.getLinks(TestHTML)
    assert links.include?("http://example.com/test.htm")
    assert links.include?("test2.htm")
    assert links.include?("/index.htm")
    assert links.include?("mailto:nobody@example.com")
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
    absoluteURLs=@linkfinder.convertToAbsolute(
      relativeURLs,
      URI("http://example.com/d1/base.htm")
    )
    assert absoluteURLs.include?(URI("http://google.com"))
    assert absoluteURLs.include?(URI("http://example.com/d1/target1.htm"))
    assert absoluteURLs.include?(URI("http://example.com/target2.htm"))
    assert absoluteURLs.include?(URI("http://example.com/d1/d2/target3.htm"))
    assert absoluteURLs.include?(URI("http://example.com/target4.htm"))
    assert absoluteURLs.include?(URI("mailto:me@example.com"))
  
    absoluteURLs=@linkfinder.convertToAbsolute(
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

  TestImg=
<<EOF
  <html>
  <head>
  <title>Image URL extraction test case</title>
  </head>
  <body>
  Here comes an image!
  <img src="http://example.com/img.png"/>
  </body>
  </html>
EOF
  
  def test_links_img
    links = @linkfinder.getLinks(TestImg)
    assert links.include?("http://example.com/img.png")
  end

  TestStylesheet=
<<EOF
  <html>
  <head>
  <link href="http://example.com/stylesheet.css" rel="stylesheet" type="text/css"/>
  <title>Stylesheet extraction test case</title>
  </head>
  <body>
  There is a stylesheet at the top of this page that should get found.
  </body>
  </html>
EOF

  def test_links_img
    links = @linkfinder.getLinks(TestStylesheet)
    assert links.include?("http://example.com/stylesheet.css")
  end

end
