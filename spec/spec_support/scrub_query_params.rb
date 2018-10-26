# frozen_string_literal: true

module ScrubQueryParams
  module_function

  def scrub(uri, params)
    uri = Addressable::URI.parse(uri)
    query_values = uri.query_values

    Array(params).each do |param|
      query_values[param] = "<SCRUBBED_#{param}>" if query_values.key?(param)
    end

    uri.query_values = query_values

    uri
  end
end
