provider "newrelic" {
  account_id = var.new_relic_account_id    # Your New Relic account ID
  api_key = var.new_relic_user_key          # Your New Relic user key
  region = "US"        
}

provider "aws" {
  region = var.region
}
