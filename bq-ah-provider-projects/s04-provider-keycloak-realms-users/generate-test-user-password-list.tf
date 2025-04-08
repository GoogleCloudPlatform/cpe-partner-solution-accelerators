# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "local_file" "test_users_password" {
  for_each = local.templates

  content  = <<EOT
%{ for user_name,user in var.provider_managed_projects ~}
${user_name}=${random_password.cx_managed_pw[user_name].result}
%{ endfor ~}
EOT
  filename = "${path.module}/../generated/test_users_password.txt"
  file_permission = 0600
}
