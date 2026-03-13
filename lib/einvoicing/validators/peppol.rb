# frozen_string_literal: true

require "open3"
require "tempfile"

module Einvoicing
  module Validators
    module Peppol
      XSLT_PATH = File.expand_path("../../data/PEPPOL-EN16931-UBL.xslt", __dir__)
      SAXON_JAR = ENV.fetch("SAXON_JAR", "/tmp/saxon-he.jar")

      # Validate a UBL 2.1 XML string against Peppol BIS Billing 3.0 schematron rules.
      # Returns array of { field:, error:, message: } hashes. Empty = valid.
      # Raises Einvoicing::Errors::JavaNotFound if java is not in PATH.
      def self.validate_ubl(xml_string)
        raise Errors::JavaNotFound, "java not found in PATH" unless java_available?
        raise Errors::ValidationError, "Saxon JAR not found at #{SAXON_JAR}. Set $SAXON_JAR or place it at #{SAXON_JAR}" unless File.exist?(SAXON_JAR)
        raise Errors::ValidationError, "Peppol XSLT not found at #{XSLT_PATH}. Run bin/download_peppol_xslt" unless File.exist?(XSLT_PATH)

        Tempfile.open(["ubl_input", ".xml"]) do |input|
          input.write(xml_string)
          input.flush

          Tempfile.open(["svrl_output", ".xml"]) do |output|
            cmd = ["java", "-jar", SAXON_JAR,
                   "-s:#{input.path}",
                   "-xsl:#{XSLT_PATH}",
                   "-o:#{output.path}"]
            _stdout, stderr, status = Open3.capture3(*cmd)
            raise Errors::ValidationError, "Saxon failed: #{stderr}" unless status.success?

            parse_svrl(File.read(output.path))
          end
        end
      end

      def self.java_available?
        system("java -version > /dev/null 2>&1")
      end

      def self.parse_svrl(svrl_xml)
        doc = Nokogiri::XML(svrl_xml)
        doc.remove_namespaces!

        doc.xpath("//failed-assert").map do |assert|
          {
            field:   assert["id"] || assert["location"] || "unknown",
            error:   assert["test"] || "assertion_failed",
            message: assert.at("text")&.text&.strip || "Assertion failed"
          }
        end
      end
    end
  end
end
