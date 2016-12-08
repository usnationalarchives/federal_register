require File.dirname(__FILE__) + '/spec_helper'

describe FederalRegister::Base do
  describe '.add_attribute' do
    it 'creates a getter method of the same name' do
      klass = Class.new(FederalRegister::Base)
      klass.add_attribute(:foo)
      instance = klass.new("foo" => "bar")
      instance.foo.should == "bar"
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
            lambda do
              instance.panda.should == "never going to get here"
            end.should raise_error
          end
        end
      end
    end

    context "when attribute is of type datetime" do
      before(:each) do
        @klass = Class.new(FederalRegister::Base)
        @klass.add_attribute(:updated_at, :type => :datetime)
      end

      context "when value is nil" do
        it "should return nil" do
          instance = @klass.new('updated_at' => nil)
          instance.updated_at.should be_nil
        end
      end

      context "when value is a DateTime" do
        it "returns a datetime" do
          datetime = DateTime.current
          instance = @klass.new('updated_at' => datetime)
          instance.updated_at.should == datetime
        end
      end

      context "when value is not a datetime" do
        context "when value is a valid datetime string" do
          it "returns the datetime" do
            time_string = "2011-10-21T08:45:00-04:00" #"2011-09-29T08:45:00-04:00"
            instance = @klass.new('updated_at' => time_string)
            instance.updated_at.should == DateTime.parse(time_string)
          end
        end

        context "when value is not a valid date string" do
          it "throws" do
            date_string = "foo"
            instance = @klass.new(:updated_at => date_string)
            lambda do
              instance.updated_at.should == '?'
            end.should raise_error
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
      FederalRegister::Base.override_base_uri('https://www.federalregister.gov/api/v1')
    end
  end
end
