require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Document do
  describe ".find" do
    it "fetches the document by its document number" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/#{document_number}.json",
        :content_type =>"text/json",
        :body => {:title => "Important Notice"}.to_json
      )

      FederalRegister::Document.find(document_number).title.should == 'Important Notice'
    end

    it "fetches the document with only requested fields (when present)" do
      document_number = "2010-213"
      params = URI.encode_www_form([["fields[]","title"],["fields[]", "start_page"]])

      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/#{document_number}.json?#{params}",
        :content_type => "text/json",
        :body => {:title => "Important Notice", :start_page => 12345}.to_json
      )

      result = FederalRegister::Document.find(document_number, :fields => ["title", "start_page"])
      result.title.should eql("Important Notice")
      result.start_page.should eql(12345)
      result.end_page.should be(nil)
    end

    it "fetches the document with the provided publication date (when present)" do
      document_number = "2010-213"
      publication_date = "2010-02-02"
      params = URI.encode_www_form([["publication_date", "#{publication_date}"]])
      
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/#{document_number}.json?#{params}",
        :content_type => "text/json",
        :body => {:title => "Important Notice", :publication_date => publication_date}.to_json
      )

      result = FederalRegister::Document.find(document_number, :publication_date => publication_date)
      result.title.should eql("Important Notice")
      result.publication_date.should eql(Date.parse(publication_date))
    end

    it "throws an error when a document doesn't exist" do
      document_number = "some-random-document"
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/#{document_number}.json",
        :content_type =>"text/json",
        :status => 404
      )
      lambda{ FederalRegister::Document.find(document_number) }.should raise_error FederalRegister::Client::RecordNotFound
    end
  end

  describe ".find_all" do
    it "fetches multiple matching documents" do
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/abc,def.json",
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc"}, {:document_number => "def"}]}.to_json
      )
      result_set = FederalRegister::Document.find_all('abc','def')
      result_set.results.map(&:document_number).sort.should === ['abc','def']
    end

    it "fetches multiple matching documents with only requested fields (when present)" do
      params = URI.encode_www_form([["fields[]","document_number"],["fields[]", "title"]])
      
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/abc,def.json?#{params}",
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "abc", :title => "Important Notice"},
                               {:document_number => "def", :title => "Important Rule"}]}.to_json
      )
      result_set = FederalRegister::Document.find_all('abc','def', :fields => ["document_number", "title"])
      result_set.results.map(&:document_number).sort.should === ['abc','def']
      result_set.results.map(&:title).sort.should === ['Important Notice','Important Rule']
      result_set.results.map(&:start_page).should === [nil, nil]
    end

    it "handles results when no documents are returned" do
      params = URI.encode_www_form([["fields[]","document_number"],["fields[]", "title"]])
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/bad_document_number,.json?#{params}",
        :content_type =>"text/json",
        :body => {"count":0,"results":[],"errors":{"not_found":["bad_docuemnt_number"]}}.to_json
      )

      result_set = FederalRegister::Document.find_all('bad_document_number', :fields => ["document_number", "title"])
      result_set.count.should == 0
    end

    it "appends a trailing comma when a single document is provided to ensure API interface doesn't return a single document" do
      params = URI.encode_www_form([["fields[]","document_number"],["fields[]", "title"]])
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/2016-26522,.json?#{params}",
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "2016-26522", :title => "Important Notice"}],
         }.to_json
      )

      FederalRegister::Document.find_all('2016-26522', :fields => ["document_number", "title"])
    end

    it "ensures document or citation numbers provided are unique before making requests to API Core." do
      # Without calling unique, duplicate results could be returned since we're now batching up larger requests.
      params = URI.encode_www_form([["fields[]","document_number"],["fields[]", "title"]])
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/2016-26522,.json?fields[]=#{params}",
        :content_type =>"text/json",
        :body => {:results => [{:document_number => "2016-26522", :title => "Important Notice"}],
         }.to_json
      )
      FederalRegister::Document.find_all('2016-26522', '2016-26522', :fields => ["document_number", "title"])
    end

    #TODO: Add specs aroudn API response
    it "batches up large requests when CGI parameters exceed the URL limit and returns the correct" do
      params = URI.encode_www_form([["fields[]","document_number"],["fields[]", "title"]])
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/2016-26000,2016-26001,2016-26002,2016-26003,2016-26004,2016-26005,2016-26006,2016-26007,2016-26008,2016-26009,2016-26010,2016-26011,2016-26012,2016-26013,2016-26014,2016-26015,2016-26016,2016-26017,2016-26018,2016-26019,2016-26020,2016-26021,2016-26022,2016-26023,2016-26024,2016-26025,2016-26026,2016-26027,2016-26028,2016-26029,2016-26030,2016-26031,2016-26032,2016-26033,2016-26034,2016-26035,2016-26036,2016-26037,2016-26038,2016-26039,2016-26040,2016-26041,2016-26042,2016-26043,2016-26044,2016-26045,2016-26046,2016-26047,2016-26048,2016-26049,2016-26050,2016-26051,2016-26052,2016-26053,2016-26054,2016-26055,2016-26056,2016-26057,2016-26058,2016-26059,2016-26060,2016-26061,2016-26062,2016-26063,2016-26064,2016-26065,2016-26066,2016-26067,2016-26068,2016-26069,2016-26070,2016-26071,2016-26072,2016-26073,2016-26074,2016-26075,2016-26076,2016-26077,2016-26078,2016-26079,2016-26080,2016-26081,2016-26082,2016-26083,2016-26084,2016-26085,2016-26086,2016-26087,2016-26088,2016-26089,2016-26090,2016-26091,2016-26092,2016-26093,2016-26094,2016-26095,2016-26096,2016-26097,2016-26098,2016-26099,2016-26100.json?#{params}",
        :content_type =>"text/json",
        :body => {:results => [
          {:document_number => "2016-26000", :title => "Important Notice"},
          #...
        ]}.to_json
      )
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/2016-26101,2016-26102,2016-26103,2016-26104,2016-26105,2016-26106,2016-26107,2016-26108,2016-26109,2016-26110,2016-26111,2016-26112,2016-26113,2016-26114,2016-26115,2016-26116,2016-26117,2016-26118,2016-26119,2016-26120,2016-26121,2016-26122,2016-26123,2016-26124,2016-26125,2016-26126,2016-26127,2016-26128,2016-26129,2016-26130,2016-26131,2016-26132,2016-26133,2016-26134,2016-26135,2016-26136,2016-26137,2016-26138,2016-26139,2016-26140,2016-26141,2016-26142,2016-26143,2016-26144,2016-26145,2016-26146,2016-26147,2016-26148,2016-26149,2016-26150,2016-26151,2016-26152,2016-26153,2016-26154,2016-26155,2016-26156,2016-26157,2016-26158,2016-26159,2016-26160,2016-26161,2016-26162,2016-26163,2016-26164,2016-26165,2016-26166,2016-26167,2016-26168,2016-26169,2016-26170,2016-26171,2016-26172,2016-26173,2016-26174,2016-26175,2016-26176,2016-26177,2016-26178,2016-26179,2016-26180,2016-26181,2016-26182,2016-26183,2016-26184,2016-26185,2016-26186,2016-26187,2016-26188,2016-26189,2016-26190,2016-26191,2016-26192,2016-26193,2016-26194,2016-26195,2016-26196,2016-26197,2016-26198,2016-26199,2016-26200.json?#{params}",
        :content_type =>"text/json",
        :body => {:results => [
          {:document_number => "2016-26000", :title => "Important Notice"},
          #...
        ]}.to_json
      )

      document_numbers = []
      doc_suffix = 26000
      201.times { document_numbers << "2016-#{doc_suffix}"; doc_suffix += 1 }

      result_set = FederalRegister::Document.find_all(*document_numbers, :fields => ["document_number", "title"])

      result_set.count.should       == 2
      result_set.previous.should    == nil
      result_set.next.should        == nil
      result_set.total_pages.should == nil
    end
  end

  describe ".search" do
    before(:each) do
      params = URI.encode_www_form([["conditions[term]","Fish"]])
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents.json?#{params}",
        :content_type =>"text/json",
        :body => {:count => 3}.to_json
      )
    end

    it "returns a resultset object" do
      FederalRegister::Document.search(:conditions => {:term => "Fish"}).should be_an_instance_of(FederalRegister::ResultSet)
    end
  end

  describe "#full_text_xml" do
    it "fetches the full_text_xml from the full_text_xml_url" do
      url = "http://example.com/full_text"
      document = FederalRegister::Document.new("full_text_xml_url" => url)
      FakeWeb.register_uri(
        :get,
        url,
        :content_type =>"text/xml",
        :body => "hello, world!"
      )
      document.full_text_xml.should == 'hello, world!'
    end
  end

  describe "#publication_date" do
    it "returns a Date object" do
      document = FederalRegister::Document.new("publication_date" => "2011-07-22")
      document.publication_date.should == Date.strptime("2011-07-22")
    end
  end

  describe "#docket_ids" do
    it "returns an array" do
      document_number = "2010-213"
      FakeWeb.register_uri(
        :get,
        "https://www.federalregister.gov/api/v1/documents/#{document_number}.json",
        :content_type =>"text/json",
        :body => {:title => "Important Notice", :docket_ids => ['ABC','123']}.to_json
      )

      FederalRegister::Document.find(document_number).docket_ids.should == ['ABC','123']
    end
  end
end
