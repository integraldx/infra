resource cloudflare_zone integraldx_me {
  account_id = var.cloudflare_account_id
  zone = "integraldx.me"
}

resource cloudflare_record vpn_integraldx_me {
  zone_id = cloudflare_zone.integraldx_me.id
  name = "vpn"
  value = var.homelab_public_ipv4
  type = "A"
}
