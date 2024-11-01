resource "random_pet" "service_name" {
  length = 3 # Generate a three-word name
}

locals {
  service_name = "${random_pet.service_name.id}.global.ssl.fastly.net"
}

# Fastly service definition
resource "fastly_service_vcl" "test_service" {
  name = local.service_name

  # Define backend for the service
  backend {
    address       = "data.geonet.org.nz"
    override_host = "data.geonet.org.nz"
    name          = "nginx_backend"
    port          = 443
  }


  healthcheck {
    name              = "nginx_health_check"
    host              = local.service_name
    check_interval    = 60000
    expected_response = 200
    timeout           = 5000
    method            = "GET"
    http_version      = "1.1"
    path              = "/"
    threshold         = 1
    window            = 2
  }

  # Add a domain for the service
  domain {
    name = local.service_name
  }

  vcl {
    content = file("${path.module}/external/main.vcl")
    main    = true
    name    = "custom"
  }

  force_destroy = true
}

output "fastly_service" {
  value = {
    service_name   = local.service_name
    activate       = fastly_service_vcl.test_service.activate
    active_version = fastly_service_vcl.test_service.active_version
  }
}
