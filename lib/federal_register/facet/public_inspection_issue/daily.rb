class FederalRegister::Facet::PublicInspectionIssue::Daily < FederalRegister::Facet::PublicInspectionIssue
  def self.url
    '/public-inspection-issues/facets/daily'
  end

  private

  def filing_class
    FederalRegister::Facet::PublicInspectionIssue::DailyFiling
  end
end
