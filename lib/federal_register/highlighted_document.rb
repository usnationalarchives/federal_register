class FederalRegister::HighlightedDocument < FederalRegister::Base
  class InvalidPhotoSize < StandardError; end

  add_attribute :curated_abstract,
                :curated_title,
                :document_number,
                :html_url,
                :photo

  VALID_PHOTO_SIZES = [
    'full_size',
    'homepage',
    'large',
    'medium',
    'navigation',
    'small'
  ].freeze

  def photo_url(size)
    unless VALID_PHOTO_SIZES.include?(size)
      raise InvalidPhotoSize,
        "valid photo sizes are #{VALID_PHOTO_SIZES.join(', ')}"
    end

    if attributes['photo']
      attributes['photo']['urls'][size]
    end
  end

  def photo_credit
    @credit ||= PhotoCredit.new(attributes['photo']['credit']) if attributes['photo']
  end

  class PhotoCredit
    attr_reader :name, :url

    def initialize(attributes)
      @name = attributes['name']
      @url = attributes['url']
    end
  end
end
