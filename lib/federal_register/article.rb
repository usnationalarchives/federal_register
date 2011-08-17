class FederalRegister::Article < FederalRegister::Base
  ATTRIBUTES = [
    :abstract,
    :abstract_html_url,
    :action,
    :agencies,
    :body_html_url,
    :cfr_references,
    :comments_close_on,
    :dates,
    :docket_id,
    :document_number,
    :effective_on,
    :end_page,
    :full_text_xml_url,
    :html_url,
    :json_url,
    :mods_url,
    :pdf_url,
    :publication_date,
    :regulation_id_numbers,
    :start_page,
    :title,
    :type,
    :volume
  ]
  
  def self.search(args)
    FederalRegister::ResultSet.fetch("/articles.json", :query => args, :result_class => self)
  end
  
  def self.find(document_number)
    attributes = get("/articles/#{document_number}.json")
    new(attributes, :full => true)
  end

  def self.find_all(*document_numbers)
    result_set = FederalRegister::ResultSet.fetch("/articles/#{document_numbers.join(',')}.json", :result_class => self)
  end
  
  def agencies
    attributes["agencies"].map do |attr|
      FederalRegister::Agency.new(attr)
    end
  end
  
  %w(full_text_xml abstract_html body_html mods).each do |file_type|
    define_method file_type do
      self.class.get(attributes["#{file_type}_url"]).body
    end
  end
end
