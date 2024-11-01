terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = "5.14.0"
    }
  }
}

provider "fastly" {
  # api_key = "test"
}
