def route(version = 'ipv4')
  anycast_ip = node['exabgp'][version]['anycast']
  return anycast_ip.kind_of?(String) ? [anycast_ip] : anycast_ip
end

def ipv6_next_hop
  cmd = Mixlib::ShellOut.new("ip route get #{node['exabgp']['ipv6']['neighbor']}")
  cmd.run_command
  next_hop = cmd.stdout.match(/src ([\w\d\:]+)/)[1]
  return (next_hop || node['ip6address'])
end
