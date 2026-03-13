# frozen_string_literal: true

module Einvoicing
  module PPF
    Error               = Class.new(StandardError)
    AuthenticationError = Class.new(Error)
    AuthorizationError  = Class.new(Error)
    NotFoundError       = Class.new(Error)
    APIError            = Class.new(Error)
    ValidationError     = Class.new(Error)
  end
end
