applySpecVersion: 1
spec:
  configSync:
    enabled: ${config_sync_enabled}
    sourceFormat: ${source_format}
    syncRepo: ${sync_repo}
    syncBranch: ${sync_branch}
    syncRev: ${sync_revision}
    secretType: ${secret_type}
%{ if secret_type == "gcpserviceaccount" && gcp_service_account_email != "" ~}
    gcpServiceAccountEmail: ${gcp_service_account_email}
%{ endif ~}
    policyDir: ${policy_dir}