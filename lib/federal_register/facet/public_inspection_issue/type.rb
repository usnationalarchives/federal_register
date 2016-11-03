class FederalRegister::Facet::PublicInspectionIssue::Type < FederalRegister::Facet::PublicInspectionIssue
  def self.url
    '/public-inspection-issues/facets/type'
  end

  private

  def filing_class
    FederalRegister::Facet::PublicInspectionIssue::TypeFiling
  end
end
