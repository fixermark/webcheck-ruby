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

