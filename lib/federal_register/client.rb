class FederalRegister::Client
  include HTTParty

  class ResponseError < HTTParty::ResponseError
    def message
      response.body
    end

    def to_s
      message
    end
  end

  class BadRequest < ResponseError; end
  class GatewayTimeout < ResponseError; end
  class RecordNotFound < ResponseError; end
  class ServerError < ResponseError; end
  class ServiceUnavailable < ResponseError; end

  base_uri 'https://www.federalregister.gov/api/v1'

  def self.get(url, *options)
    response = super

    case response.code
    when 200
      response
    when 400
      raise BadRequest.new(response)
    when 404
      raise RecordNotFound.new(response)
    when 500
      raise ServerError.new(response)
    when 503
      raise ServiceUnavailable.new(response)
    when 504
      raise GatewayTimeout.new(response)
    else
      raise HTTParty::ResponseError.new(response)
    end
  end
end
