output "onpremdnsa_ip" {
    value = aws_instance.onpremdnsa.private_ip
}

output "onpremdnsb_ip" {
    value = aws_instance.onpremdnsb.private_ip
}

output "onpremvpc_id" {
  value = aws_vpc.onpremvpc.id
}

output "onprem-private-rt_id" {
    value = aws_route_table.onprem-private-rt.id
}
