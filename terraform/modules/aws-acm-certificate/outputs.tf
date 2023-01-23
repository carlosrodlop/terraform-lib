output "certificate_arn" {
  description = "The AWS ARN of the certificate"
  value       = aws_acm_certificate.this.arn
}
