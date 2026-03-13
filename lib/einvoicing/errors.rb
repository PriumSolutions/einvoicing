# frozen_string_literal: true

module Einvoicing
  module Errors
    # Raised when Java is not found in PATH and is required for validation.
    JavaNotFound = Class.new(StandardError)

    # Raised when an external validator (e.g. Saxon) fails unexpectedly.
    ValidationError = Class.new(StandardError)
  end
end
