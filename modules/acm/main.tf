/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  config_sync_apply_spec_filename          = "${var.cluster_name}_config-sync-apply-spec.yaml"
  config_sync_apply_spec_template_filename = "${path.module}/templates/config-sync-apply-spec.yml.tpl"
}

module "enable_acm" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"

  platform              = "linux"
  upgrade               = true
  additional_components = ["beta"]

  service_account_key_file = var.service_account_key_file
  create_cmd_entrypoint    = "gcloud"
  create_cmd_body          = "beta container hub config-management enable --project ${var.project_id}"
  destroy_cmd_entrypoint   = "gcloud"
  destroy_cmd_body         = "beta container hub config-management disable --force --project ${var.project_id}"
}

data "template_file" "config_sync_apply_spec" {

  template = file(local.config_sync_apply_spec_template_filename)

  vars = {
    config_sync_enabled       = var.config_sync_enabled
    gcp_service_account_email = var.gcp_service_account_email
    policy_dir                = var.policy_dir 
    secret_type               = var.secret_type
    source_format             = var.source_format
    sync_branch               = var.sync_branch
    sync_repo                 = var.sync_repo
    sync_revision             = var.sync_revision
    sync_wait                 = var.sync_wait
  }
}

resource "local_file" "config_sync_apply_spec" {
  content  = data.template_file.config_sync_apply_spec.rendered
  filename = local.config_sync_apply_spec_filename
}

module "configure_config_sync" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"

  platform              = "linux"
  upgrade               = true
  additional_components = ["beta"]

  service_account_key_file = var.service_account_key_file
  create_cmd_entrypoint    = "gcloud"
  create_cmd_body          = "beta container hub config-management apply --config=${local_file.config_sync_apply_spec.filename} --membership=${var.cluster_name} --project=${var.project_id}"
}
