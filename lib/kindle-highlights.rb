require 'rubygems'
require 'mechanize'
require 'asin'

class KindleHighlight
  attr_accessor :highlights
  attr_accessor :next_url, :fetched

  def initialize(email_address, password)
    @highlights = Array.new
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'
    @fetched = false

    page = @agent.get("https://www.amazon.com/ap/signin?openid.assoc_handle=amzn_kindle&openid.pape.max_auth_age=0&pageId=amzn_kindle&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.return_to=https%3A%2F%2Fkindle.amazon.com%3A443%2Fauthenticate%2Flogin_callback%3Fwctx%3D%252F")
    @amazon_form = page.form('signIn')
    @amazon_form.email = email_address
    @amazon_form.password = password
  end

  def scrape_highlights(should_lookup_book=true)
    if self.next_url.nil?
      signin_submission = @agent.submit(@amazon_form)
      highlights_page = @agent.click(signin_submission.link_with(:text => /Your Highlights/))
      self.fetched = true
    else
      highlights_page = @agent.get(self.next_url)
    end

    new_highlights = Array.new
    highlights_page.search(".//div[@class='highlightRow yourHighlight']").each do |highlight|
      new_highlights << Highlight.new(highlight, should_lookup_book)
    end
    self.highlights = self.highlights + new_highlights
    self.next_url = highlights_page.search("a#nextBookLink").attribute('href') rescue nil
    new_highlights
  end

  def has_more?
    !self.fetched || (self.fetched && !self.next_url.nil?)
  end
end

class KindleHighlight::Highlight
  include ASIN::Client

  attr_accessor :annotation_id, :asin, :end_location, :note
  attr_accessor :details_url, :image_url, :title, :author, :content

  @@amazon_items = Hash.new

  def initialize(highlight, should_lookup_book=true)
    self.annotation_id = highlight.xpath("form/input[@id='annotation_id']").attribute("value").value 
    self.asin = highlight.xpath("p/span[@class='hidden asin']").text
    self.content = highlight.xpath("span[@class='highlight']").text rescue ""
    self.note = highlight.xpath("span[@class='noteContent']").text rescue ""
    self.end_location = highlight.xpath("span[@class='end_location']").text
    lookup_item if should_lookup_book
  end

  def lookup_item
    amazon_item = lookup_or_get_from_cache(self.asin)
    self.title = amazon_item.title
    self.author = amazon_item.raw.ItemAttributes.Author rescue nil
    self.details_url = amazon_item.details_url
    self.image_url = amazon_item.image_url
  end

  def to_s
    "<Highlight##{annotation_id}>"
  end

  private
  def lookup_or_get_from_cache(asin)
    unless @@amazon_items.has_key?(asin)
      @@amazon_items[asin] = lookup(asin).first
    end
    @@amazon_items[asin]
  end
end