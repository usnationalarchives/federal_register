require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::ResultSet do
  describe "#next" do
    it "loads the next_page_url" do
      FakeWeb.register_uri(:get, "https://www.federalregister.gov/api/v1/fishes?page=2", :body => {:count => 24}.to_json, :content_type =>"text/json")
      FederalRegister::ResultSet.new({'next_page_url' => 'https://www.federalregister.gov/api/v1/fishes?page=2'}, FederalRegister::Document).next.count.should == 24
    end
  end

  describe "enumerability" do
    it "responds to #each" do
      FederalRegister::ResultSet.new({}, FederalRegister::Document).should respond_to(:each)
    end

    it "includes Enumerable" do
      FederalRegister::ResultSet.should include(Enumerable)
    end

    context "given an empty result set" do
      it "never invokes the block" do
        results = FederalRegister::ResultSet.new({}, FederalRegister::Document)
        lambda do
          results.each {|i| fail i }
        end.should_not raise_error
      end
    end

    context "given a non-empty result set" do
      before(:each) do
        @results = FederalRegister::ResultSet.new({'results' => [
                                                                 {'panda' => 'bamboo'},
                                                                 {'curry' => 'noodle'},
                                                                 {'soup' => 'tree'}
                                                                ]}, FederalRegister::Document)
      end

      it "doesn't yields nil to a block" do
        @results.each do |result|
          result.should_not be_nil
        end
      end

      it "invokes the block once for each result" do
        @results.map {|result| result }.should == @results.results
      end

      it "yields the proper elements to the block" do
        @results.map {|r| r }.should == @results.results
      end
    end
  end
end
