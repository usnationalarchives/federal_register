class FederalRegister::Article < FederalRegister::Base
  ATTRIBUTES = [
    :title,
    :type,
    :abstract,
    :document_number,
    :html_url,
    :pdf_url,
    :publication_date,
    :agencies,
    :full_text_xml_url,
    :abstract_html_url,
    :body_html_url,
    :mods_url,
    :action,
    :dates,
    :effective_on,
    :comments_close_on,
    :start_page,
    :end_page,
    :volume,
    :docket_id,
    :regulation_id_numbers,
    :cfr_references,
    :json_url
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
