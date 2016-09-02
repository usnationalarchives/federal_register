class FederalRegister::DocumentImage < FederalRegister::Document
  def identifier
    attributes[0]
  end

  def sizes
    attributes[1].keys
  end

  def url_for(size)
    attributes[1][size]
  end

  def default_url
    sizes.include?('original_png') ? url_for('original_png') : url_for('original')
  end
end
