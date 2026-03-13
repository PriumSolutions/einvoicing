# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Einvoicing
  # Looks up SIRET and company name from a SIREN number using the free French
  # government API (no authentication required).
  module SiretLookup
    API_URL = "https://recherche-entreprises.api.gouv.fr/search"
    SIREN_RE = /\A\d{9}\z/

    # Find company info for a given SIREN number.
    #
    # @param siren [String, nil] 9-digit SIREN number
    # @return [Hash, nil] { siret:, name:, address: } or nil on any error
    def self.find(siren)
      return nil unless siren.to_s.match?(SIREN_RE)

      uri = URI(API_URL)
      uri.query = URI.encode_www_form(q: siren, mtq: "true")

      response = fetch(uri)
      return nil if response.nil?

      parse(response)
    rescue StandardError
      nil
    end

    def self.fetch(uri)
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == "https",
                      open_timeout: 5,
                      read_timeout: 10) do |http|
        res = http.get("#{uri.path}?#{uri.query}")
        return nil unless res.is_a?(Net::HTTPSuccess)

        res.body
      end
    rescue StandardError
      nil
    end
    private_class_method :fetch

    def self.parse(body)
      data = JSON.parse(body)
      result = Array(data["results"]).first
      return nil unless result

      siege = result["siege"] || {}
      siret = siege["siret"]
      return nil if siret.nil? || siret.empty?

      { siret: siret, name: result["nom_complet"], address: siege["adresse"] }
    rescue JSON::ParserError
      nil
    end
    private_class_method :parse
  end
end
