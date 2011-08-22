require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Article do
  describe ".find" do
    it "fetches the document by its document number" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "http://www.federalregister.gov/api/v1/articles/#{document_number}.json", 
        :content_type =>"text/json",
        :body => {:title => "Important Notice"}.to_json
      )

      FederalRegister::Article.find(document_number).title.should == 'Important Notice'
    end

    it "throws an error when a document doesn't exist" do
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

  describe ".find_all" do
    it "fetches multiple matching documents" do
      FakeWeb.register_uri(
        :get,
        "http://www.federalregister.gov/api/v1/articles/abc,def.json", 
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc"}, {:document_number => "def"}]}.to_json
      )
      result_set = FederalRegister::Article.find_all('abc','def')
      result_set.results.map(&:document_number).sort.should === ['abc','def']
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

    it "returns a resultset object" do
      FederalRegister::Article.search(:conditions => {:term => "Fish"}).should be_an_instance_of(FederalRegister::ResultSet)
    end
  end

  describe "#full_text_xml" do
    it "fetches the full_text_xml from the full_text_xml_url" do
      url = "http://example.com/full_text"
      article = FederalRegister::Article.new("full_text_xml_url" => url)
      FakeWeb.register_uri(
        :get,
        url,
        :content_type =>"text/xml",
        :body => "hello, world!"
      )
      article.full_text_xml.should == 'hello, world!'
    end
  end

  describe "#publication_date" do
    it "returns a Date object" do
      article = FederalRegister::Article.new("publication_date" => "2011-07-22")
      article.publication_date.should == Date.strptime("2011-07-22") 
    end
  end
end
