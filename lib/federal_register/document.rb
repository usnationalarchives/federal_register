class FederalRegister::Document < FederalRegister::Base
  extend FederalRegister::Utilities

  add_attribute :abstract,
                :abstract_html_url,
                :action,
                :agencies,
                :agency_names,
                :body_html_url,
                :cfr_references,
                :citation,
                :comment_url,
                :corrections,
                :correction_of,
                :dates,
                :docket_id,
                :docket_ids,
                :document_number,
                :end_page,
                :excerpts,
                :executive_order_notes,
                :executive_order_number,
                :full_text_xml_url,
                :html_url,
                :images,
                :json_url,
                :mods_url,
                :pdf_url,
                :president,
                :public_inspection_pdf_url,
                :regulation_id_number_info,
                :regulation_id_numbers,
                :regulations_dot_gov_info,
                :regulations_dot_gov_url,
                :significant,
                :start_page,
                :subtype,
                :raw_text_url,
                :title,
                :toc_subject,
                :toc_doc,
                :type,
                :volume

  add_attribute :comments_close_on,
                :effective_on,
                :publication_date,
                :signing_date,
                :type => :date

  def self.search(args)
    FederalRegister::ResultSet.fetch("/documents.json", :query => args, :result_class => self)
  end

  def self.search_metadata(args)
    FederalRegister::ResultSet.fetch("/documents.json", :query => args.merge(:metadata_only => '1'), :result_class => self)
  end

  def self.find(document_number, options={})
    if options[:fields].present?
      attributes = get("/documents/#{document_number}.json", :query => {:fields => options[:fields]})
      new(attributes)
    else
      attributes = get("/documents/#{document_number}.json")
      new(attributes, :full => true)
    end
  end

  def self.find_all(*args)
    options, document_numbers = extract_options(args)

    fetch_options = {:result_class => self}
    fetch_options.merge!(:query => {:fields => options[:fields]}) if options[:fields]

    document_numbers = document_numbers.flatten

    #TODO: fix this gross hack to ensure that find_all with a single document number
    # is returned in the same way multiple document numbers are
    if document_numbers.size == 1
      document_numbers << " "
    end

    result_set = FederalRegister::ResultSet.fetch("/documents/#{document_numbers.join(',').strip}.json", fetch_options)
  end

  def agencies
    attributes["agencies"].map do |attr|
      FederalRegister::Agency.new(attr)
    end
  end

  %w(full_text_xml abstract_html body_html raw_text mods).each do |file_type|
    define_method file_type do
      begin
        self.class.get(send("#{file_type}_url")).body
      rescue FederalRegister::Client::RecordNotFound
        nil
      rescue
        raise send("#{file_type}_url").inspect
       end
    end
  end

  def images
    if attributes["images"]
      attributes["images"].map do |attributes|
        FederalRegister::DocumentImage.new(attributes)
      end
    else
      []
    end
  end
end
