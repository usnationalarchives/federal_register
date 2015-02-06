require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::PublicInspectionDocument do
  describe ".find" do
    it "fetches the document by its document number" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/public-inspection-documents/#{document_number}.json", 
        :content_type =>"text/json",
        :body => {:title => "Important Notice"}.to_json
      )

      FederalRegister::PublicInspectionDocument.find(document_number).title.should == 'Important Notice'
    end

    it "throws an error when a document doesn't exist" do
      document_number = "some-random-document"
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/public-inspection-documents/#{document_number}.json", 
        :content_type =>"text/json",
        :status => 404
      )
      lambda{ FederalRegister::PublicInspectionDocument.find(document_number) }.should raise_error FederalRegister::Client::RecordNotFound
    end
  end

  describe ".find_all" do
    it "fetches multiple matching documents" do
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/public-inspection-documents/abc,def.json", 
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc"}, {:document_number => "def"}]}.to_json
      )
      result_set = FederalRegister::PublicInspectionDocument.find_all('abc','def')
      result_set.results.map(&:document_number).sort.should === ['abc','def']
    end
  end

  describe ".available_on" do
    it "fetches the document on PI on a given date" do
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/public-inspection-documents.json?conditions[available_on]=2011-10-15", 
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc"}, {:document_number => "def"}]}.to_json
      )
      result_set = FederalRegister::PublicInspectionDocument.available_on(Date.parse('2011-10-15'))
      result_set.results.map(&:document_number).sort.should === ['abc','def']
    end
  end

  describe ".current" do
    it "fetches the PI documents from the current issue" do
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/public-inspection-documents/current.json", 
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc"}, {:document_number => "def"}]}.to_json
      )
      result_set = FederalRegister::PublicInspectionDocument.current
      result_set.results.map(&:document_number).sort.should === ['abc','def']
    end
  end

end
