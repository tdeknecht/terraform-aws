# ------------------------------------------------------------------------------
# stack overflow https://stackoverflow.com/questions/75367169/how-to-use-a-list-from-an-external-data-source-with-terraform
# ------------------------------------------------------------------------------

data "http" "googlebot" {
  url = "https://developers.google.com/static/search/apis/ipranges/googlebot.json"

  request_headers = {
    Accept = "application/json"
  }
}

output googlebot_ip_prefixes { value = data.http.googlebot.body }