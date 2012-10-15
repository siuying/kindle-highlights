require 'spec_helper'
require 'kindle-highlights'

describe KindleHighlight do
  let(:kindle) {
    KindleHighlight.new(ENV["USERNAME"], ENV["PASSWORD"])
  }

  before(:all) do 
    ENV["USERNAME"].should_not be_nil
    ENV["PASSWORD"].should_not be_nil
    ENV["ASIN_SECRET"].should_not be_nil
    ENV["ASIN_KEY"].should_not be_nil
    ENV["ASIN_ASSOCIATE"].should_not be_nil
    
    ASIN::Configuration.configure do |config|
      config.secret        = ENV['ASIN_SECRET']
      config.key           = ENV['ASIN_KEY']
      config.associate_tag = ENV['ASIN_ASSOCIATE']
    end
  end

  describe "get first page of highlights" do
    it "should get highlights" do
      kindle.scrape_highlights
      kindle.highlights.size.should > 0
      first_highlight = kindle.highlights.first
      first_highlight.author.should_not be_nil
    end
  end
end