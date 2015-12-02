class FederalRegister::PublicInspectionDocument < FederalRegister::Base
  add_attribute :agencies,
                :docket_numbers,
                :document_number,
                :editorial_note,
                :excerpts,
                :html_url,
                :filing_type,
                :pdf_url,
                :pdf_file_size,
                :num_pages,
                :title,
                :toc_doc,
                :toc_subject,
                :type

  add_attribute :publication_date,
                :type => :date
  add_attribute :filed_at,
                :pdf_update_at,
                :type => :datetime

  def self.search(args)
    FederalRegister::ResultSet.fetch("/public-inspection-documents.json", :query => args, :result_class => self)
  end

  def self.search_metadata(args)
    FederalRegister::ResultSet.fetch("/public-inspection-documents.json", :query => args.merge(:metadata_only => '1'), :result_class => self)
  end

  def self.find(document_number)
    attributes = get("/public-inspection-documents/#{document_number}.json")
    new(attributes, :full => true)
  end

  def self.available_on(date)
    FederalRegister::PublicInspectionIssueResultSet.fetch("/public-inspection-documents.json", :query => {:conditions => {:available_on => date}}, :result_class => self)
  end

  def self.current
    FederalRegister::PublicInspectionIssueResultSet.fetch("/public-inspection-documents/current.json", :result_class => self)
  end

  def self.find_all(*document_numbers)
    result_set = FederalRegister::ResultSet.fetch("/public-inspection-documents/#{document_numbers.join(',')}.json", :result_class => self)
  end

  def agencies
    attributes["agencies"].map do |attr|
      FederalRegister::Agency.new(attr)
    end
  end
end
