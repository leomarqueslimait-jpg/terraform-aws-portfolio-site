output "endpoint_url" {
  description = "Full API endpoint URL - paste this into index.html as API_ENDPOINT"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/contacts"
}