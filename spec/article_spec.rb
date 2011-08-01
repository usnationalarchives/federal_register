require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Article do
  describe ".find" do
    it "should fetch the document by its document number" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "http://www.federalregister.gov/api/v1/articles/#{document_number}.json", 
        :content_type =>"text/json",
        :body => {:title => "Important Notice"}.to_json
      )
      
      FederalRegister::Article.find(document_number).title.should == 'Important Notice'
    end
    
    it "should throw an error when a document doesn't exist" do
      document_number = "some-random-document"
      FakeWeb.register_uri(
        :get,
        "http://www.federalregister.gov/api/v1/articles/#{document_number}.json", 
        :content_type =>"text/json",
        :status => 404
      )
      lambda{ FederalRegister::Article.find(document_number) }.should raise_error FederalRegister::Client::RecordNotFound
    end
  end
  
  describe ".search" do
    before(:each) do
      FakeWeb.register_uri(
        :get,
        "http://www.federalregister.gov/api/v1/articles.json?conditions[term]=Fish", 
        :content_type =>"text/json",
        :body => {:count => 3}.to_json
      )
    end
    
    it "should return a resultset object" do
      FederalRegister::Article.search(:conditions => {:term => "Fish"}).should be_an_instance_of(FederalRegister::ResultSet)
    end
  end
end
