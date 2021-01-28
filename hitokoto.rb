require "open-uri"
require "nokogiri"

# 名言集.com のランダムページをスクレイピングさせてもらう
def fetch_hitokoto
  charset = nil
  url = "http://www.meigensyu.com/quotations/view/random"
  html = open(url) do |f|
    charset = f.charset
    f.read
  end

  path = '//*[@id="contents_box"]/div[2]/div[1]'
  doc = Nokogiri::HTML.parse(html, nil, charset)

  doc.xpath(path).inject("") { |result, node| node.inner_text }
end
