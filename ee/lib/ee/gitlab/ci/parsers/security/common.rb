# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Parsers
        module Security
          module Common
            extend ::Gitlab::Utils::Override

            private

            # map remediations to relevant vulnerabilities
            def collate_remediations
              return report_data["vulnerabilities"] || [] unless report_data["remediations"]

              report_data["vulnerabilities"].map do |vulnerability|
                remediation = fixes[vulnerability['id']] || fixes[vulnerability['cve']]
                vulnerability.merge("remediations" => [remediation])
              end
            end

            def fixes
              @fixes ||= report_data['remediations'].each_with_object({}) do |item, memo|
                item['fixes'].each do |fix|
                  id = fix['id'] || fix['cve']
                  memo[id] = item if id
                end
                memo
              end
            end

            def create_remediations(remediations_data)
              remediations_data.to_a.compact.map do |remediation_data|
                ::Gitlab::Ci::Reports::Security::Remediation.new(remediation_data['summary'], remediation_data['diff'])
              end
            end

            override :create_findings
            def create_findings
              collate_remediations.each { |finding| create_finding(finding, create_remediations(report_data['remediations'])) }
            end
          end
        end
      end
    end
  end
end
