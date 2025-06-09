terraform {
  # Require the latest 2.x version of the New Relic provider
  required_providers {
    newrelic = {
      source  = "registry.terraform.io/newrelic/newrelic"
    }
  }
}

########################################## NewRelic Alarm Destination ###############################################

resource "newrelic_notification_destination" "newrelic_alarm_destination" {
  account_id = var.new_relic_account_id
  name = "bankapp-destination"
  type = "EMAIL"

  property {
    key = "email"
    value = "abc@gmail.com"  ### Provide Group Email ID here
  }
}

########################################## NewRelic Notification Channel ############################################

resource "newrelic_notification_channel" "email_channel" {
  name    = "bankapp-channnel"
  type    = "EMAIL"
  product = "IINT" # Required for NR Alerts channels
  destination_id = newrelic_notification_destination.newrelic_alarm_destination.id
  property {
    key   = "recipients"
    value = "abc@gmail.com"  ### Provide Group Email ID here
  }
}

########################################## NewRelic Alert Policy ####################################################

resource "newrelic_alert_policy" "alert_policy" {
  name = "bankapp-policy"
  incident_preference = "PER_POLICY" 
}

########################################## NewRelic Alert Workflow ##################################################

resource "newrelic_workflow" "newrelic_workflow" {
  name = "bankapp-workflow"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"  ### send notifications always, no matter whether the issue is muted or not

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.alert_policy.id ]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.email_channel.id
  }
}

########################################### NewRelic Alert Conditions ###############################################

resource "newrelic_nrql_alert_condition" "cpu_utilization" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "static"
  name = "CPU-Utilization-BankApp"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT average(cpuPercent) FROM SystemSample FACET entityName WHERE hostname IN ('docker-server', 'jenkins-master', 'jenkins-slave')"
  }

  critical {
    operator = "above"
    threshold = 70
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
}

resource "newrelic_nrql_alert_condition" "memory_utilization" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "static"
  name = "Memory-Utilization-BankApp"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT average(memoryUsedPercent) FROM SystemSample FACET entityName WHERE hostname IN ('docker-server', 'jenkins-master', 'jenkins-slave')"
  }

  critical {
    operator = "above"
    threshold = 70
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
}

resource "newrelic_nrql_alert_condition" "disk_utilization" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "static"
  name = "Disk-Utilization-BankApp"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT average(diskUsedPercent) FROM SystemSample FACET entityName WHERE hostname IN ('docker-server', 'jenkins-master', 'jenkins-slave')"
  }

  critical {
    operator = "above"
    threshold = 70
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
}

########################################## Synthetic Monitoring of BankApp URL and SSL ######################################################

resource "newrelic_synthetics_monitor" "ping_url" {
  name = "BankApp URL Synthetic Monitoring"
  type = "SIMPLE"
  status = "ENABLED"  ### You Need to Enable it after Creation of BankApp URL.
  period = "EVERY_MINUTE"  # Run every minute
  locations_public = ["AP_EAST_1", "AP_SOUTH_1", "AP_SOUTHEAST_1", "AP_NORTHEAST_1", "AP_NORTHEAST_2", "AP_SOUTHEAST_2", "US_WEST_1", "US_WEST_2", "US_EAST_2", "US_EAST_1", "CA_CENTRAL_1", "SA_EAST_1", "EU_WEST_1", "EU_WEST_2", "EU_WEST_3", "EU_CENTRAL_1", "EU_NORTH_1", "EU_SOUTH_1", "ME_SOUTH_1", "AF_SOUTH_1"]
  uri = "https://bankapp.singhritesh85.com/login"
  verify_ssl = true
}

#resource "newrelic_synthetics_cert_check_monitor" "ssl_monitor" {
#  name                   = "SSL Certificate Expiration"
#  domain                 = "bankapp.singhritesh85.com"
#  locations_public = ["AP_EAST_1", "AP_SOUTH_1", "AP_SOUTHEAST_1", "AP_NORTHEAST_1", "AP_NORTHEAST_2", "AP_SOUTHEAST_2", "US_WEST_1", "US_WEST_2", "US_EAST_2", "US_EAST_1", "CA_CENTRAL_1", "SA_EAST_1", "EU_WEST_1", "EU_WEST_2", "EU_WEST_3", "EU_CENTRAL_1", "EU_NORTH_1", "EU_SOUTH_1", "ME_SOUTH_1", "AF_SOUTH_1"]
#  certificate_expiration = "30"
#  period                 = "EVERY_DAY"
#  status                 = "ENABLED"
#  runtime_type           = "NODE_API"
#  runtime_type_version   = "16.10"
#  tag {
#    key    = "project"
#    values = ["BankApp"]
#  }
#}

#################################################### NewRelic Alert Condition ##############################################################

# Alert for BankApp URL Synthetic Monitoring
resource "newrelic_nrql_alert_condition" "bankapp_synthetic_monitor" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "static"
  name = "BankApp-URL-Monitoring"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${newrelic_synthetics_monitor.ping_url.id}') AND NOT isMuted FACET location, monitorName"
  }

  critical {
    operator = "above"
    threshold = 0
    threshold_duration = 60
    threshold_occurrences = "at_least_once"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer = 5
}

# Alert for SSL Certificate Expiration
#resource "newrelic_nrql_alert_condition" "ssl_monitoring" {
#  account_id = var.new_relic_account_id
#  policy_id = newrelic_alert_policy.alert_policy.id
#  type = "static"
#  name = "Alert for SSL Certificate Expiration"
#  enabled = true
#  violation_time_limit_seconds = 259200
#  nrql {
#    query = "SELECT latest(DaysToExpiration) * -1 FROM SSLCertificateCheck"
# }

#  critical {
#    operator = "below_or_equals"
#    threshold = 350
#    threshold_duration = 60
#    threshold_occurrences = "at_least_once"
#  }

#  warning {
#    operator = "below_or_equals"
#    threshold = 350
#    threshold_duration = 60
#    threshold_occurrences = "at_least_once"
#  }
#  fill_option = "none"
#  aggregation_window = 60
#  aggregation_method = "event_timer"
#  aggregation_timer = 5
#}

################################################ NewRElic Alert for APM ######################################################

resource "newrelic_nrql_alert_condition" "low_application_throughput" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "baseline"
  name = "Low Application Throughput"
  enabled = true
  violation_time_limit_seconds = 259200    ### Automatically Close Alarm after 3 days

  nrql {
    query = "SELECT average(`newrelic.goldenmetrics.apm.application.throughput`) FROM Metric FACET entity.guid, appName"
    data_account_id = var.new_relic_account_id
  }

  critical {
    operator = "above"
    threshold = 3
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
  expiration_duration = 600
  open_violation_on_expiration = true
  close_violations_on_expiration = true
  ignore_on_expected_termination = false
  baseline_direction = "lower_only"
  signal_seasonality = "new_relic_calculation"
}

resource "newrelic_nrql_alert_condition" "newrelic_apm_response_time" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "baseline"
  name = "APM Resonse Time"
  enabled = true
  violation_time_limit_seconds = 259200    ### Automatically Close Alarm after 3 days

  nrql {
    query = "SELECT average(`newrelic.goldenmetrics.apm.application.responseTimeMs`) FROM Metric FACET entity.guid, appName"
    data_account_id = var.new_relic_account_id
  }

  critical {
    operator = "above"
    threshold = 3
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
  expiration_duration = 600
  open_violation_on_expiration = true
  close_violations_on_expiration = true
  ignore_on_expected_termination = false
  baseline_direction = "lower_only"
  signal_seasonality = "new_relic_calculation"
}

resource "newrelic_nrql_alert_condition" "newrelic_apm_error_rate" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "baseline"
  name = "APM Error Rate"
  enabled = true
  violation_time_limit_seconds = 259200    ### Automatically Close Alarm after 3 days

  nrql {
    query = "SELECT average(`newrelic.goldenmetrics.apm.application.errorRate`) FROM Metric FACET entity.guid, appName"
    data_account_id = var.new_relic_account_id
  }

  critical {
    operator = "above"
    threshold = 3
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
  expiration_duration = 600
  open_violation_on_expiration = true
  close_violations_on_expiration = true
  ignore_on_expected_termination = false
  baseline_direction = "lower_only"
  signal_seasonality = "new_relic_calculation"
}

resource "newrelic_nrql_alert_condition" "bankapp_container_cpu_utilization" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "static"
  name = "BankApp Container CPU Utilization"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT max(docker.container.cpuPercent) or max(k8s.container.cpuCoresUtilization) AS 'CPU utilization (%)' FROM Metric WHERE ContainerSample.name IN ('bankapp') FACET entity.name"
  }

  critical {
    operator = "above"
    threshold = 90
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
}

resource "newrelic_nrql_alert_condition" "mysql_container_cpu_utilization" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "static"
  name = "MySQL Container CPU Utilization"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT max(docker.container.cpuPercent) or max(k8s.container.cpuCoresUtilization) AS 'CPU utilization (%)' FROM Metric WHERE ContainerSample.name IN ('mysql') FACET entity.name"
  }

  critical {
    operator = "above"
    threshold = 90
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
}

resource "newrelic_nrql_alert_condition" "bankapp_memory_bytes_used" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "baseline"
  name = "BankApp Memory Bytes Used"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT max(docker.container.memoryUsageBytes) or max(k8s.container.memoryWorkingSetBytes) AS 'Memory used (bytes)' FROM Metric WHERE ContainerSample.name IN ('bankapp') FACET entity.name"
  }

  critical {
    operator = "above"
    threshold = 3
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
  baseline_direction = "upper_only"
  signal_seasonality = "new_relic_calculation"
}


resource "newrelic_nrql_alert_condition" "mysql_memory_bytes_used" {
  account_id = var.new_relic_account_id
  policy_id = newrelic_alert_policy.alert_policy.id
  type = "baseline"
  name = "MySQL Memory Bytes Used"
  enabled = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT max(docker.container.memoryUsageBytes) or max(k8s.container.memoryWorkingSetBytes) AS 'Memory used (bytes)' FROM Metric WHERE ContainerSample.name IN ('mysql') FACET entity.name"
  }

  critical {
    operator = "above"
    threshold = 3
    threshold_duration = 300
    threshold_occurrences = "all"
  }
  fill_option = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay = 120
  baseline_direction = "upper_only"
  signal_seasonality = "new_relic_calculation"
}
