import initSecurityPoliciesList from 'ee/threat_monitoring/security_policies_list';
import { NAMESPACE_TYPES } from 'ee/threat_monitoring/constants';

initSecurityPoliciesList(
  document.getElementById('js-security-policies-list'),
  NAMESPACE_TYPES.PROJECT,
);
