import { isEmpty } from 'lodash';
import { s__, n__ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import { EXTENSION_ICONS } from '~/vue_merge_request_widget/constants';
import { parseDependencies } from './utils';

// TODO: Clean up both status versions as part of https://gitlab.com/gitlab-org/gitlab/-/issues/356206
const APPROVAL_STATUS_TO_ICON = {
  allowed: EXTENSION_ICONS.success,
  denied: EXTENSION_ICONS.failed,
  unclassified: EXTENSION_ICONS.notice,
};

export default {
  name: 'WidgetLicenseCompliance',
  i18n: {
    label: s__('ciReport|License Compliance'),
    loading: s__('ciReport|License Compliance test metrics results are being parsed'),
    error: s__('ciReport|License Compliance failed loading results'),
  },
  expandEvent: 'i_testing_license_compliance_widget_total',
  props: ['licenseCompliance'],
  enablePolling: true,
  enableExpandedPolling: true,
  computed: {
    newLicenses() {
      return this.collapsedData.new_licenses || 0;
    },
    existingLicenses() {
      return this.collapsedData.existing_licenses || 0;
    },
    deniedLicenses() {
      return this.collapsedData.denied_licenses || 0;
    },
    licenseReportCount() {
      return this.newLicenses();
    },
    hasReportItems() {
      return this.licenseReportCount() > 0;
    },
    hasBaseReportLicenses() {
      return this.existingLicenses() > 0;
    },
    hasDeniedLicense() {
      return this.deniedLicenses() > 0;
    },
    shouldCollapse() {
      return this.hasReportItems();
    },
    tertiaryButtons() {
      return [
        {
          text: s__('ciReport|Manage Licenses'),
          href: this.licenseCompliance.license_scanning.settings_path,
          target: '_blank',
        },
        {
          text: s__('ciReport|Full Report'),
          href: this.licenseCompliance.license_scanning.full_report_path,
          target: '_blank',
        },
      ];
    },
    hasApprovalRequired() {
      return Boolean(this.collapsedData.approval_required);
    },
    summaryTextWithReportItems() {
      if (this.hasApprovalRequired() && this.hasDeniedLicense()) {
        if (this.hasBaseReportLicenses()) {
          return n__(
            'LicenseCompliance|License Compliance detected %d new license and policy violation; approval required',
            'LicenseCompliance|License Compliance detected %d new licenses and policy violations; approval required',
            this.licenseReportCount(),
          );
        }
        return n__(
          'LicenseCompliance|License Compliance detected %d license and policy violation for the source branch only; approval required',
          'LicenseCompliance|License Compliance detected %d licenses and policy violations for the source branch only; approval required',
          this.licenseReportCount(),
        );
      }

      if (this.hasBaseReportLicenses() && !this.hasDeniedLicense()) {
        return n__(
          'LicenseCompliance|License Compliance detected %d new license',
          'LicenseCompliance|License Compliance detected %d new licenses',
          this.licenseReportCount(),
        );
      } else if (this.hasBaseReportLicenses() && this.hasDeniedLicense()) {
        return n__(
          'LicenseCompliance|License Compliance detected %d new license and policy violation',
          'LicenseCompliance|License Compliance detected %d new licenses and policy violations',
          this.licenseReportCount(),
        );
      } else if (!this.hasBaseReportLicenses() && this.hasDeniedLicense()) {
        return n__(
          'LicenseCompliance|License Compliance detected %d license and policy violation for the source branch only',
          'LicenseCompliance|License Compliance detected %d licenses and policy violations for the source branch only',
          this.licenseReportCount(),
        );
      }
      return n__(
        'LicenseCompliance|License Compliance detected %d license for the source branch only',
        'LicenseCompliance|License Compliance detected %d licenses for the source branch only',
        this.licenseReportCount(),
      );
    },
    summary() {
      if (this.hasReportItems()) {
        return this.summaryTextWithReportItems();
      }

      if (this.hasBaseReportLicenses()) {
        return s__('LicenseCompliance|License Compliance detected no new licenses');
      }
      return s__(
        'LicenseCompliance|License Compliance detected no licenses for the source branch only',
      );
    },
    statusIcon() {
      if (this.newLicenses() === 0) {
        return EXTENSION_ICONS.success;
      }
      return EXTENSION_ICONS.warning;
    },
  },
  methods: {
    fetchCollapsedData() {
      const { license_scanning_comparison_collapsed_path } = this.licenseCompliance;

      return this.fetchReport(license_scanning_comparison_collapsed_path);
    },
    fetchFullData() {
      const { license_scanning_comparison_path } = this.licenseCompliance;

      return this.fetchReport(license_scanning_comparison_path).then((res) => {
        const { data = {} } = res;

        if (isEmpty(data)) {
          return { ...res, data };
        }

        let newLicenses = data.new_licenses;

        newLicenses = newLicenses.map((e) => ({
          status: e.classification.approval_status,
          icon: {
            name: APPROVAL_STATUS_TO_ICON[e.classification.approval_status],
          },
          link: {
            href: e.url,
            text: e.name,
          },
          supportingText: `${s__('License Compliance| Used by')} ${parseDependencies(
            e.dependencies,
          )}`,
        }));

        const groupedLicenses = newLicenses.reduce(
          (licenses, license) => ({
            ...licenses,
            [license.status]: [...(licenses[license.status] || []), license],
          }),
          {},
        );

        // TODO: Clean up both status versions as part of https://gitlab.com/gitlab-org/gitlab/-/issues/356206
        const licenseSections = [
          ...(groupedLicenses.denied?.length > 0
            ? [
                {
                  header: s__('LicenseCompliance|Denied'),
                  text: s__(
                    "LicenseCompliance|Out-of-compliance with the project's policies and should be removed",
                  ),
                  children: groupedLicenses.denied || groupedLicenses.blacklisted,
                },
              ]
            : []),
          ...(groupedLicenses.unclassified?.length > 0
            ? [
                {
                  header: s__('LicenseCompliance|Uncategorized'),
                  text: s__('LicenseCompliance|No policy matches this license'),
                  children: groupedLicenses.unclassified,
                },
              ]
            : []),
          ...(groupedLicenses.allowed?.length > 0
            ? [
                {
                  header: s__('LicenseCompliance|Allowed'),
                  text: s__('LicenseCompliance|Acceptable for use in this project'),

                  children: groupedLicenses.allowed || groupedLicenses.approved,
                },
              ]
            : []),
        ];
        return { ...res, data: licenseSections };
      });
    },
    fetchReport(endpoint) {
      return axios.get(endpoint);
    },
  },
};
