require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Base do
  describe '.add_attribute' do
    it 'creates a getter method of the same name' do
      klass = Class.new(FederalRegister::Base)
      klass.add_attribute(:foo)
      instance = klass.new("foo" => "bar")
      instance.foo.should == "bar"
    end

    it 'creates a getter method that lazy loads the full data' do
      klass = Class.new(FederalRegister::Base)
      klass.add_attribute(:foo, :json_url)
      instance = klass.new('json_url' => 'http://example.com/details')
      FakeWeb.register_uri(
        :get,
        "http://example.com/details", 
        :content_type =>"text/json",
        :body => {:foo => "bar"}.to_json
      )
      instance.foo.should == 'bar'
    end
  end

  describe '.override_base_uri' do
    before(:each) do
      FederalRegister::Base.override_base_uri('http://fr2.local/api/v1')
    end

    [FederalRegister::Agency, FederalRegister::Article, FederalRegister::Base, FederalRegister::Client, FederalRegister::ResultSet].each do |klass|
      it "should set default_options[:base_uri] for #{klass}" do
        klass.default_options[:base_uri].should == 'http://fr2.local/api/v1'
      end
    end
  end
end
