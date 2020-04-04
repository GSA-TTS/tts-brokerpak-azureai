# Copyright 2020 Pivotal Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable fog_instance_name { type = string }
variable server_pair_name { type = string }
variable server_pairs { type = map }

resource "null_resource" "run-failover" {

  provisioner "local-exec" {
    command = format("sqlfailover %s %s %s", 
                     var.server_pairs[var.server_pair_name].secondary.resource_group,
                     var.server_pairs[var.server_pair_name].secondary.server_name,
                     var.fog_instance_name) 
  }

  provisioner "local-exec" {
	when = destroy
    command = format("sqlfailover %s %s %s", 
                     var.server_pairs[var.server_pair_name].primary.resource_group,
                     var.server_pairs[var.server_pair_name].primary.server_name,
                     var.fog_instance_name)  
  }
}