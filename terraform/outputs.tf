output "instance_id" {
  value = aws_instance.devops.id
}

output "key_pair_name" {
  value = aws_key_pair.devops.key_name
}

output "private_key_path" {
  value = local_sensitive_file.devops_private_key.filename
}

output "public_ip" {
  value = aws_instance.devops.public_ip
}

output "ssh_command" {
  value = "ssh -i ../Devops_Lab_App.pem ubuntu@${aws_instance.devops.public_ip}"
}