# encoding: UTF-8

output "configuration" {
  value = <<CONFIGURATION

Visit the static website hosted on S3:
  Prod: ${terraform_remote_state.aws_global.output.prod_fqdn}
        ${terraform_remote_state.aws_global.output.prod_endpoint}

  Staging: ${terraform_remote_state.aws_global.output.staging_fqdn}
           ${terraform_remote_state.aws_global.output.staging_endpoint}

  Region: ${module.website.fqdn}
          ${module.website.endpoint}

Visit the Node.js website:
  Node.js (blue): ${module.compute.nodejs_blue_private_fqdn}
                  ${module.compute.nodejs_blue_elb_dns}

  Node.js (green): ${module.compute.nodejs_green_private_fqdn}
                   ${module.compute.nodejs_green_elb_dns}

  HAProxy: ${module.compute.haproxy_public_fqdn}
           ${join("\n           ", formatlist("http://%s/", split(",", module.compute.haproxy_public_ips)))}

Add your private key and SSH into any private node via the Bastion host:
  ssh-add ../../../modules/keys/demo.pem
  ssh -A ${module.network.bastion_user}@${module.network.bastion_public_ip}

Private node IPs:
  Consul: ${join("\n          ", formatlist("ssh ubuntu@%s", split(",", module.data.consul_private_ips)))}

  Vault: ${join("\n         ", formatlist("ssh ubuntu@%s", split(",", module.data.vault_private_ips)))}

  HAProxy: ${join("\n           ", formatlist("ssh ubuntu@%s", split(",", module.compute.haproxy_private_ips)))}

The VPC environment is accessible via an OpenVPN connection:
  Server:   ${module.network.openvpn_public_fqdn}
            ${module.network.openvpn_public_ip}
  Username: ${var.openvpn_admin_user}
  Password: ${var.openvpn_admin_pw}

You can administer the OpenVPN Access Server:
  https://${module.network.openvpn_public_fqdn}/admin
  https://${module.network.openvpn_public_ip}/admin

Once you're on the VPN, you can...

Visit the Consul UI:
  http://consul.service.consul:8500/ui/

Use Consul DNS:
  ssh ubuntu@consul.service.consul
  ssh ubuntu@vault.service.consul
  ssh ubuntu@haproxy.service.consul
  ssh ubuntu@web.service.consul
  ssh ubuntu@nodejs.web.service.consul

Visit the HAProxy stats page:
  http://haproxy.service.consul:1936/haproxy?stats
  http://${module.compute.haproxy_private_fqdn}:1936/haproxy?stats
  ${join("\n  ", formatlist("http://%s:1936/haproxy?stats", split(",", module.compute.haproxy_private_ips)))}

Interact with Vault:
  Vault: ${module.data.vault_private_fqdn}
         ${module.data.vault_elb_dns}
CONFIGURATION
}
