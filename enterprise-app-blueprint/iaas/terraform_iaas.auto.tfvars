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

# Images
# SQL Server 2019 Standard: windows-sql-cloud    sql-std-2019-win-2019
# Windows Server 2019 DC: windows-cloud    windows-2019
# Ubuntu 2204 LTS: ubuntu-os-cloud      ubuntu-2204-lts

admin_vms_noauto = {
  # ADC
  adsrv = {
    location = "fra"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-main"
    ip = "10.11.0.10"
    comment = "Role: Active Directory + ADFS"
    image = "windows-cloud/windows-2019"
  }
}

admin_vms = {
  jumphost = {
    location = "fra"
    machine-type = "e2-standard-2"
    gpus = []
    network = "main"
    subnet = "fra-main"
    ip = "10.11.0.20"
    comment = "Role: Linux Jumphost"
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
  adminws = {
    location = "fra"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-main"
    ip = "10.11.0.30"
    comment = "Role: Admin Workstation"
    image = "windows-cloud/windows-2019"
  }
}

app_vms = {
  # Web Tier
  web1 = {
    location = "fra"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-webtier"
    ip = "10.11.20.10"
    comment = "Role: Web Server 1"
    image = "windows-cloud/windows-2019"
  }
  web2 = {
    location = "fra"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-webtier"
    ip = "10.11.20.11"
    comment = "Role: Web Server 2"
    image = "windows-cloud/windows-2019"
  }

  # Application Tier
  app1 = {
    location = "fra"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-enttier"
    ip = "10.11.30.10"
    comment = "Role: Business Logic Server 1"
    image = "windows-cloud/windows-2019"
  }
  app2 = {
    location = "fra"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-enttier"
    ip = "10.11.30.11"
    comment = "Role: Business Logic Server 2"
    image = "windows-cloud/windows-2019"
  }
  appgpu1 = {
    location = "fra"
    machine-type = "n1-standard-8"
    zone = "europe-west3-b"
    gpus = [{
       type = "nvidia-tesla-t4"
       count = 1
    }]
    on_host_maintenance = "TERMINATE"
    network = "main"
    subnet = "fra-enttier"
    ip = "10.11.30.12"
    comment = "Role: App Server with GPU"
    image = "windows-cloud/windows-2019"
  }

  # Storage Tier
  db1 = {
    location = "fra"
    machine-type = "n2-standard-4"
    gpus = []
    network = "main"
    subnet = "fra-restier"
    ip = "10.11.40.10"
    comment = "Role: Self Hosted Database"
    image = "windows-sql-cloud/sql-std-2019-win-2019"
  }

  # Multi-site Site 2 Web Tier
  site2web1 = {
    location = "bel"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "bel-webtier"
    ip = "10.33.20.10"
    comment = "Role: Web Server 3 (Geo Region 2)"
    image = "windows-cloud/windows-2019"
  }

  # Multi-site Site 2 Application Tier
  site2app1 = {
    location = "bel"
    machine-type = "e2-standard-4"
    gpus = []
    network = "main"
    subnet = "bel-enttier"
    ip = "10.33.30.21"
    comment = "Role: Business Logic Server 1 (Geo Region 2)"
    image = "windows-cloud/windows-2019"
  }

  # DMZ Site Web Tier
  dmzweb1 = {
    location = "fra-dmz"
    machine-type = "e2-standard-4"
    gpus = []
    network = "dmz"
    subnet = "fra-dmz-webtier"
    ip = "10.22.20.10"
    comment = "Role: Web Server 4 (DMZ)"
    image = "windows-cloud/windows-2019"
  }

  # DMZ Site Application Tier
  dmzapp1 = {
    location = "fra-dmz"
    machine-type = "e2-standard-4"
    gpus = []
    network = "dmz"
    subnet = "fra-dmz-enttier"
    ip = "10.22.30.10"
    comment = "Role: Business Logic Server 1 (DMZ)"
    image = "windows-cloud/windows-2019"
  }

}

networks = {
  # Main network for the two sites of a georahpically distributed environment
  main = {
    nat_regions = [ "europe-west1", "europe-west3" ]
    managed_ad_cidr = "10.100.0.0/24"
  }
  # DMZ network for public / shared integrations
  dmz = {
    nat_regions = [ "europe-west3" ]
    managed_ad_cidr = "10.100.0.0/24"
  }
}

sites = {
  fra = {
    network = "main"
    region = "europe-west3"
    zone = "europe-west3-a"
    sec_zone = "europe-west3-b"
    subnets = {
      fra-main = "10.11.0.0/24"
      fra-clients = "10.11.10.0/24"
      fra-webtier = "10.11.20.0/24"
      fra-enttier = "10.11.30.0/24"
      fra-restier = "10.11.40.0/24"
    }
    proxy_subnet = "10.11.100.0/24"
    psc_subnet = "10.11.101.0/24"
    vpc_connector_subnet = "10.11.102.0/28" # Last IP 10.11.102.15
  }
  bel = {
    network = "main"
    region = "europe-west1"
    zone = "europe-west1-b"
    sec_zone = "europe-west1-c"
    subnets = {
      bel-webtier = "10.33.20.0/24"
      bel-enttier = "10.33.30.0/24"
      bel-restier = "10.33.40.0/24"
    }
    proxy_subnet = "10.33.100.0/24"
    psc_subnet = "10.33.101.0/24"
    vpc_connector_subnet = "10.33.102.0/28" # Last IP 10.11.102.15
  }
  fra-dmz = {
    network = "dmz"
    region = "europe-west3"
    zone = "europe-west3-a"
    sec_zone = "europe-west3-b"
    subnets = {
      fra-dmz-webtier = "10.22.20.0/24"
      fra-dmz-enttier = "10.22.30.0/24"
      fra-dmz-restier = "10.22.40.0/24"
    }
    proxy_subnet = "10.22.100.0/24"
    psc_subnet = "10.22.101.0/24"
    vpc_connector_subnet = "10.22.102.0/28" # Last IP 10.11.102.15
  }
}
