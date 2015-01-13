class FederalRegister::PublicInspectionIssueResultSet < FederalRegister::ResultSet
  attr_reader :regular_filings_updated_at, :special_filings_updated_at

  def initialize(attributes, result_class)
    super attributes, result_class

    @regular_filings_updated_at = attributes['regular_filings_updated_at']
    @special_filings_updated_at = attributes['special_filings_updated_at']
  end
end
