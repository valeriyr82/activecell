module Intuit
  # Helper class used for parsing xml with Intuit companies
  # @see https://services.intuit.com/sb/company/v2/availableList
  class AvailableListXmlParser
    attr_reader :xml
    attr_reader :doc

    def initialize(xml)
      @xml = xml
      @doc = Nokogiri::XML.parse(xml)
      @doc.remove_namespaces!
    end

    # Returns company's data for the given realm
    def find_by_realm(realm)
      element = doc.xpath("/RestResponse/CompaniesMetaData/CompanyMetaData/ExternalRealmId[text()=#{realm}]/..")

      unless element.empty?
        name = element.xpath('QBNRegisteredCompanyName').first.text
        sign_up_at = Time.parse(element.xpath('CompanySignUpDateTime').first.text)
        { realm: realm, name: name, sign_up_at: sign_up_at }
      end
    end
  end
end
