module FederalRegister::Utilities

  private
  def extract_options(array)
    options = array.last.is_a?(::Hash) ? array.pop : {}
    [options, array]
  end
end
