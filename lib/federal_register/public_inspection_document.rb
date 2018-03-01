class FederalRegister::PublicInspectionDocument < FederalRegister::Base
  extend FederalRegister::Utilities

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
    attributes = get("/public-inspection-documents/#{document_number}.json").parsed_response
    new(attributes, :full => true)
  end

  def self.available_on(date)
    FederalRegister::PublicInspectionIssueResultSet.fetch("/public-inspection-documents.json", :query => {:conditions => {:available_on => date}}, :result_class => self)
  end

  def self.current
    FederalRegister::PublicInspectionIssueResultSet.fetch("/public-inspection-documents/current.json", :result_class => self)
  end

  def self.find_all(*args)
    options, document_numbers = extract_options(args)

    fetch_options = {:result_class => self}
    fetch_options.merge!(:query => {:fields => options[:fields]}) if options[:fields]

    #TODO: fix this gross hack to ensure that find_all with a single document number
    # is returned in the same way multiple document numbers are
    if document_numbers.size == 1
      document_numbers << " "
    end

    result_set = FederalRegister::ResultSet.fetch("/public-inspection-documents/#{document_numbers.join(',').strip}.json", fetch_options)
  end

  def agencies
    attributes["agencies"].map do |attr|
      FederalRegister::Agency.new(attr)
    end
  end
end
