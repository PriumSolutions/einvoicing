# frozen_string_literal: true

require_relative "fr/siret_lookup"

module Einvoicing
  module FR
    # France-specific features for the einvoicing gem.
    # Market: France (FR) — Factur-X, PPF/PDP mandate (Sept 2026)
    #
    # Usage:
    #   Einvoicing::FR::SiretLookup.find("898208145")
    #   Einvoicing::FR::SiretLookup.enrich!(party)
  end
end
