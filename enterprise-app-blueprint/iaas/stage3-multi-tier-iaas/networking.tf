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

locals {
  locations_subnets = flatten([
    for location_key, location in var.sites : [
      for subnet_key, subnet in location.subnets : {
        location_key       = location_key
        location           = location
        subnet_key         = subnet_key
        subnet             = subnet
      }
    ]
  ])

  proxy_subnets = flatten([
    for location_key, location in var.sites : {
        location_key       = location_key
        network_key        = location.network
        region             = location.region
        proxy_subnet       = location.proxy_subnet
    }
  ])

}

data "google_compute_network" "vpc_network" {
  for_each                 = var.networks

  name                     = "vpc-${each.key}"
}

data "google_compute_subnetwork" "vpc_subnet" {
  for_each = tomap({
    for subnet in local.locations_subnets : "${subnet.subnet_key}" => subnet
  })

  region        = each.value.location.region
  name          = "vpc-subnetwork-${each.key}"
}

data "google_compute_subnetwork" "proxy_subnet" {
  for_each = tomap({
    for proxy_subnet in local.proxy_subnets : proxy_subnet.location_key => proxy_subnet
  })

  region        = each.value.region
  name          = "proxy-subnet-${each.key}"
}
