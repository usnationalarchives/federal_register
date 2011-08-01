require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::ResultSet do
  describe "#next" do
    it "should load the next_page_url" do
      FakeWeb.register_uri(:get, "http://www.federalregister.gov/api/v1/fishes?page=2", :body => {:count => 24}.to_json, :content_type =>"text/json")
      FederalRegister::ResultSet.new({'next_page_url' => 'http://www.federalregister.gov/api/v1/fishes?page=2'}, FederalRegister::Article).next.count.should == 24
    end
  end
end
