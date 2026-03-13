# frozen_string_literal: true

module SchemaValidation
  def validate_against_xsd(xml_string, schema_name)
    require "nokogiri"
    schema_path = File.expand_path("../../lib/einvoicing/schemas/facturx/#{schema_name}", __dir__)
    xsd_file = Dir["#{schema_path}/**/*.xsd"].find do |f|
      f.include?("CrossIndustryInvoice") || f.include?("EN16931")
    end
    return [] unless xsd_file

    # Change to the schema directory so that relative XSD imports resolve correctly.
    schema = Dir.chdir(File.dirname(xsd_file)) do
      Nokogiri::XML::Schema(File.read(xsd_file))
    end
    doc = Nokogiri::XML(xml_string)
    schema.validate(doc)
  end
end
