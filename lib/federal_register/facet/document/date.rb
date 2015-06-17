class FederalRegister::Facet::Document::Date < FederalRegister::Facet::Document
  def self.chart_url(args={})
    uri = [base_uri, url, '.png']

    if args.present?
      uri << '?'
      uri << HTTParty::HashConversions.to_params(args)
    end

    uri.join('')
  end
end
