#
# Cookbook Name:: exabgp
# Recipe:: default
#
# Copyright 2012, DNSimple, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

systemd_enabled = ::File.open('/proc/1/comm').gets.chomp == 'systemd'

python_runtime 'system' do
  version '2'
  provider :system
end

include_recipe 'runit' unless systemd_enabled

python_package 'exabgp' do
  action :install
end unless node['recipes'].include? 'exabgp::source'

directory '/etc/exabgp'

template 'exabgp: config' do
  path '/etc/exabgp/exabgp.conf'
  source 'exabgp.conf.erb'
  variables( router_id: node['ipaddress'],
             hold_time: node['exabgp']['hold_time'],
             neighbor_ipv4: node['exabgp']['ipv4']['neighbor'],
             local_address_ipv4: node['ipaddress'],
             local_preference: node['exabgp']['local_preference'],
             route_ipv4: route('ipv4'),
             enable_ipv4_static_route: node['exabgp']['ipv4']['enable_static_route'],
             enable_hubot: node['exabgp']['hubot']['enable'],
             neighbor_ipv6: node['exabgp']['ipv6']['neighbor'],
             local_address_ipv6: node['ip6address'],
             route_ipv6: route('ipv6'),
             local_as: node['exabgp']['local_as'],
             peer_as: node['exabgp']['peer_as'],
             community: node['exabgp']['community'].join(' '))
  mode '644'
  notifies :run, 'execute[reload-exabgp-config]' unless systemd_enabled
  notifies :reload, 'service[exabgp]' if systemd_enabled
end

template '/etc/exabgp/neighbor-changes.rb' do
  source 'neighbor-changes.rb.erb'
  variables hubot_publish: {
              url: node['exabgp']['hubot']['url'],
              secret: node['exabgp']['hubot']['secret'],
              event: node['exabgp']['hubot']['event']
            }
  mode 0755
  notifies :run, 'execute[reload-exabgp-config]' unless systemd_enabled
  notifies :reload, 'service[exabgp]' if systemd_enabled
end

execute 'reload-exabgp-config' do
  action :nothing
  command 'sv 2 exabgp'
end

runit_service 'exabgp' do
  default_logger true
end unless systemd_enabled

systemd_service 'exabgp' do
  unit do
    description 'ExaBGP service'
    after node['exabgp']['systemd']['after']
    condition_path_exists '/etc/exabgp/exabgp.conf'
  end

  service do
    environment 'exabgp_daemon_daemonize' => 'false'
    exec_start '/usr/src/exabgp/sbin/exabgp /etc/exabgp/exabgp.conf'
    exec_reload '/bin/kill -s USR1 $MAINPID'
    user 'nobody'
  end

  install do
    wanted_by 'multi-user.target'
  end

  only_if { systemd_enabled }
end

service 'exabgp' do
  action [:enable, :start]
  only_if { systemd_enabled }
end
