class FederalRegister::Base < FederalRegister::Client
  attr_reader :attributes

  def self.add_attribute(*attributes)
    options = {}

    if attributes.last.is_a?(Hash)
      options = attributes.pop
    end

    attributes.each do |attr|
      define_method attr do
        val = @attributes[attr.to_s]
        if val
          case options[:type]
          when :date
            if ! val.is_a?(Date)
              val = Date.strptime(val.to_s)
            end
          when :datetime
            if ! val.is_a?(DateTime)
              val = DateTime.parse(val.to_s)
            end
          when :integer
            if ! val.is_a?(Fixnum)
              val = val.to_i
            end
          end
        end

        val
      end
    end
  end

  def initialize(attributes = {}, options = {})
    @attributes = attributes
    @full = options[:full] || false
  end

  def full?
    @full
  end

  def fetch_full
    @attributes = self.class.get(json_url)
    @full = true
    self
  end

  # this has to be done because HTTParty uses a custom attr_inheritable
  # which copies the setting for base uri into each class at inheritance
  # time - which is before we can modify it in something like a Rails
  # initializer
  def self.override_base_uri(uri)
    [
      FederalRegister::Agency,
      FederalRegister::Article,
      FederalRegister::Base,
      FederalRegister::Client,
      FederalRegister::Document,
      FederalRegister::DocumentImages,

      FederalRegister::Facet,
      FederalRegister::Facet::Agency,
      FederalRegister::Facet::PresidentialDocumentType,
      FederalRegister::Facet::Topic,

      FederalRegister::Facet::Document::Daily,
      FederalRegister::Facet::Document::Weekly,
      FederalRegister::Facet::Document::Monthly,
      FederalRegister::Facet::Document::Quarterly,
      FederalRegister::Facet::Document::Yearly,

      FederalRegister::Facet::Document::Type,

      FederalRegister::Facet::PublicInspectionDocument,
      FederalRegister::Facet::PublicInspectionDocument::Type,

      FederalRegister::Facet::PublicInspectionIssue,
      FederalRegister::Facet::PublicInspectionIssue::Daily,
      FederalRegister::Facet::PublicInspectionIssue::DailyFiling,
      FederalRegister::Facet::PublicInspectionIssue::Type,
      FederalRegister::Facet::PublicInspectionIssue::TypeFiling,

      FederalRegister::HighlightedDocument,
      FederalRegister::PublicInspectionDocument,
      FederalRegister::Section,
      FederalRegister::SuggestedSearch,

      FederalRegister::ResultSet,
      FederalRegister::PublicInspectionIssueResultSet,
      FederalRegister::FacetResultSet,
    ].each do |klass|
      klass.base_uri(uri)
    end
  end

  attr_reader :attributes
end
