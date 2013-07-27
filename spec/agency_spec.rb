require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Agency do
  describe ".all" do
    before(:each) do
      FakeWeb.register_uri(:get, "http://api.federalregister.gov/v1/agencies.json", :body => [{},{}].to_json, :content_type =>"text/json")
    end

    it "returns Agency objects" do
      agencies = FederalRegister::Agency.all
      agencies.each do |agency|
        agency.should be_an_instance_of(FederalRegister::Agency)
      end
    end

    it "returns multiple agencies" do
      agencies = FederalRegister::Agency.all
      agencies.count.should == 2
    end
  end

  describe "attribute loading" do
    before(:each) do
      @agency = FederalRegister::Agency.new({'name' => "Commerce Department", 'json_url' => "http://api.federalregister.gov/v1/agencies/1.json"})
    end

    describe "existing attribute" do
      it "reads the from the json hash if already there" do
        @agency.name.should == 'Commerce Department'
      end
    end

    describe "non-existent attributes" do
      it "should trigger an error" do
        lambda {@agency.non_existent_attribute}.should raise_error NoMethodError
      end
    end
  end
end
