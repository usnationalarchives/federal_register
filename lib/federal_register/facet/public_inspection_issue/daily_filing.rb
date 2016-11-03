class FederalRegister::Facet::PublicInspectionIssue::DailyFiling < FederalRegister::Facet::PublicInspectionIssue
  add_attribute :agencies, :documents

  add_attribute :last_updated_at,
                :type => :datetime
end
