class FederalRegister::Article < FederalRegister::Base
  class InvalidDocumentNumber < ArgumentError; end
  add_attribute :abstract,
                :abstract_html_url,
                :action,
                :agencies,
                :body_html_url,
                :cfr_references,
                :dates,
                :docket_id,
                :docket_ids,
                :document_number,
                :end_page,
                :full_text_xml_url,
                :html_url,
                :json_url,
                :mods_url,
                :pdf_url,
                :regulation_id_numbers,
                :start_page,
                :subtype,
                :title,
                :type,
                :volume

  add_attribute :comments_close_on,
                :effective_on,
                :publication_date,
                :type => :date
 
  def self.search(args)
    FederalRegister::ResultSet.fetch("/articles.json", :query => args, :result_class => self)
  end
  
  def self.find(document_number)
    validate_document_number!(document_number)
    attributes = get("/articles/#{document_number}.json")
    new(attributes, :full => true)
  end

  def self.find_all(*document_numbers)
    document_numbers.each {|doc_num| validate_document_number!(doc_num)}
    result_set = FederalRegister::ResultSet.fetch("/articles/#{document_numbers.join(',')}.json", :result_class => self)
  end
  
  def agencies
    attributes["agencies"].map do |attr|
      FederalRegister::Agency.new(attr)
    end
  end
  
  %w(full_text_xml abstract_html body_html mods).each do |file_type|
    define_method file_type do
      self.class.get(send("#{file_type}_url")).body
    end
  end

  private

  def self.validate_document_number!(document_number)
    if document_number.blank? || document_number !~ /^[a-zA-Z0-9-]+$/
      raise InvalidDocumentNumber.new("'#{document_number}' is not a valid FR Document Number")
    end
  end
end
