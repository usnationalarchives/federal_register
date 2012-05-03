require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Article do
  describe ".find" do
    it "fetches the document by its document number" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles/#{document_number}.json", 
        :content_type =>"text/json",
        :body => {:title => "Important Notice"}.to_json
      )

      FederalRegister::Article.find(document_number).title.should == 'Important Notice'
    end

    it "fetches the document with only requested fields (when present)" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles/#{document_number}.json?fields[]=title&fields[]=start_page",
        :content_type => "text/json",
        :body => {:title => "Important Notice", :start_page => 12345}.to_json
      )

      result = FederalRegister::Article.find(document_number, :fields => ["title", "start_page"])
      result.title.should eql("Important Notice")
      result.start_page.should eql(12345)
      result.end_page.should be(nil)
    end

    it "throws an error when a document doesn't exist" do
      document_number = "some-random-document"
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles/#{document_number}.json", 
        :content_type =>"text/json",
        :status => 404
      )
      lambda{ FederalRegister::Article.find(document_number) }.should raise_error FederalRegister::Client::RecordNotFound
    end

    it "throws an error when given an invalid document number" do
      lambda{ FederalRegister::Article.find('an! invalid! document! number!') }.should raise_error FederalRegister::Article::InvalidDocumentNumber
    end
  end

  describe ".find_all" do
    it "fetches multiple matching documents" do
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles/abc,def.json", 
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc"}, {:document_number => "def"}]}.to_json
      )
      result_set = FederalRegister::Article.find_all('abc','def')
      result_set.results.map(&:document_number).sort.should === ['abc','def']
    end

    it "fetches multiple matching documents with only requested fields (when present)" do
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles/abc,def.json?fields[]=document_number&fields[]=title", 
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc", :title => "Important Notice"}, 
                               {:document_number => "def", :title => "Important Rule"}]}.to_json
      )
      result_set = FederalRegister::Article.find_all('abc','def', :fields => ["document_number", "title"])
      result_set.results.map(&:document_number).sort.should === ['abc','def']
      result_set.results.map(&:title).sort.should === ['Important Notice','Important Rule']
      result_set.results.map(&:start_page).should === [nil, nil]
    end

    it "throws an error when given an invalid document number" do
      lambda{ FederalRegister::Article.find_all('123-456','an! invalid! document! number!') }.should raise_error FederalRegister::Article::InvalidDocumentNumber
    end
  end

  describe ".search" do
    before(:each) do
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles.json?conditions[term]=Fish", 
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

  describe "#docket_ids" do
    it "returns an array" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "http://api.federalregister.gov/v1/articles/#{document_number}.json", 
        :content_type =>"text/json",
        :body => {:title => "Important Notice", :docket_ids => ['ABC','123']}.to_json
      )

      FederalRegister::Article.find(document_number).docket_ids.should == ['ABC','123']
    end
  end
end
