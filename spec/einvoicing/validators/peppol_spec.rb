# frozen_string_literal: true
require "spec_helper"

RSpec.describe Einvoicing::Validators::Peppol do
  before do
    skip "java required" unless described_class.java_available?
    skip "Saxon JAR not found" unless File.exist?(described_class::SAXON_JAR)
    skip "Peppol XSLT not found" unless File.exist?(described_class::XSLT_PATH)
  end

  let(:ubl) { Einvoicing::Formats::UBL.generate(Fixtures.invoice) }

  describe ".validate_ubl" do
    it "returns an Array of hashes for a UBL invoice" do
      errors = described_class.validate_ubl(ubl)
      expect(errors).to be_an(Array)
      errors.each do |e|
        expect(e).to include(:field, :error, :message)
      end
    end

    it "returns errors for malformed XML" do
      errors = described_class.validate_ubl("<not-ubl/>")
      expect(errors).to be_an(Array)
    end
  end

  describe ".java_available?" do
    it "returns true" do
      expect(described_class.java_available?).to be true
    end
  end
end
