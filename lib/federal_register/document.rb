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
                :disposition_notes,
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
                :page_views,
                :pdf_url,
                :president,
                :proclamation_number,
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
    query = {}
    
    if options[:publication_date].present?
      publication_date = options[:publication_date]
      publication_date = publication_date.is_a?(Date) ? publication_date.to_s(:iso) : publication_date
      
      query.merge!(:publication_date => publication_date)
    end

    if options[:fields].present?
      query.merge!(:fields => options[:fields])
    end

    attributes = get("/documents/#{document_number}.json", :query => query).parsed_response
    new(attributes, :full => true)
  end

  # supports values like: '2016-26522', '2016-26522,2016-26594', '81 FR 76496', '81 FR 76496,81 FR 76685'
  # note: no space after comma
  def self.find_all(*args)
    options, document_numbers_or_citations = extract_options(args)
    document_numbers_or_citations.flatten!

    fetch_options = {:result_class => self}
    fetch_options.merge!(:query => {:fields => options[:fields]}) if options[:fields]

    #TODO: fix this gross hack to ensure that find_all with a single document number
    # is returned in the same way multiple document numbers are
    if document_numbers_or_citations.size == 1
      document_numbers_or_citations << " "
    end

    params = URI.encode(document_numbers_or_citations.compact.join(',').strip)
    result_set = FederalRegister::ResultSet.fetch("/documents/#{params}.json", fetch_options)
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

  def page_views
    if attributes["page_views"]
      last_updated = begin
        DateTime.parse(attributes["page_views"]["last_updated"])
      rescue
        nil
      end

      {
        count: attributes["page_views"]["count"],
        last_updated: last_updated
      }
    end
  end
end
