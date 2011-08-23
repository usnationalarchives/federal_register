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

    context "when attribute is of type date" do
      before(:each) do
        @klass = Class.new(FederalRegister::Base)
        @klass.add_attribute(:panda, :type => :date)
      end

      context "when value is nil" do
        it "should return nil" do
          instance = @klass.new('panda' => nil)
          instance.panda.should be_nil
        end
      end

      context "when value is a Date" do
        it "returns a date" do
          date = Date.today
          instance = @klass.new('panda' => Date.today)
          instance.panda.should == Date.today
        end
      end

      context "when value is not a date" do
        context "when value is a valid date string" do
          it "returns the date" do
            date_string = Date.today.to_s
            instance = @klass.new('panda' => date_string)
            instance.panda.should == Date.strptime(date_string)
          end
        end

        context "when value is not a valid date string" do
          it "throws" do
            date_string = "PANDA"
            instance = @klass.new('panda' => date_string)
            lambda {
              instance.panda.should == "never going to get here"
            }.should raise_error
          end
        end
      end
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

    after(:all) do
      FederalRegister::Base.override_base_uri('http://api.federalregister.gov/v1')
    end
  end
end
