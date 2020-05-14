module FederalRegister::DocumentUtilities
  URL_CHARACTER_LIMIT = 2000

  def find_all(*args)
    options, document_numbers_or_citations = extract_options(args)
    document_numbers_or_citations.flatten!

    fetch_options = {:result_class => self}
    fetch_options.merge!(:query => {:fields => options[:fields]}) if options[:fields]

    document_numbers_or_citations.uniq!

    #TODO: fix this gross hack to ensure that find_all with a single document number
    # is returned in the same way multiple document numbers are
    if document_numbers_or_citations.size == 1
      document_numbers_or_citations << " "
    end

    http_request_batches = calculate_request_batches(document_numbers_or_citations, fetch_options)

    slice_size = (document_numbers_or_citations.count.to_f / http_request_batches).ceil
    results    = []
    document_numbers_or_citations.each_slice(slice_size).each do |slice|

      params   = URI.encode(slice.join(',').strip)
      url      = "#{find_all_base_path}/#{params}.json"
      response = get(url, fetch_options).parsed_response
      results += response['results']
    end

    FederalRegister::ResultSet.new(
      {
        'count'   => results.count,
        'results' => results,
      },
      self
    )
  end

  private

  def calculate_request_batches(document_numbers_or_citations, fetch_options)
    fetch_option_url_character_count = URI.encode_www_form(fetch_options).length # HTTPParty uses Net::HTTP
    characters_available             = URL_CHARACTER_LIMIT - fetch_option_url_character_count
    doc_number_character_count       = URI.encode(document_numbers_or_citations.compact.join(',').strip).length

    if characters_available > doc_number_character_count
      1
    else
      (doc_number_character_count.to_f / characters_available).ceil
    end
  end
end
