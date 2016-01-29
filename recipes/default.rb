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

include_recipe 'python'
include_recipe 'runit'

python_pip 'exabgp' do
  action :install
end unless node[:recipes].include? 'exabgp::source'

directory '/etc/exabgp'

template 'exabgp: config' do
  path '/etc/exabgp/exabgp.conf'
  source 'exabgp.conf.erb'
  variables( router_id: node.ipaddress,
             hold_time: node[:exabgp][:hold_time],
             neighbor_ipv4: node[:exabgp][:ipv4][:neighbor],
             local_address_ipv4: node.ipaddress,
             local_preference: node[:exabgp][:local_preference],
             route_ipv4: route('ipv4'),
             enable_ipv4_static_route: node[:exabgp][:ipv4][:enable_static_route],
             enable_hubot: node[:exabgp][:hubot][:enable],
             neighbor_ipv6: node[:exabgp][:ipv6][:neighbor],
             local_address_ipv6: ipv6_next_hop,
             route_ipv6: route('ipv6'),
             local_as: node[:exabgp][:local_as],
             peer_as: node[:exabgp][:peer_as],
             community: node[:exabgp][:community].join(' '))
  mode '644'
  notifies :run, 'execute[reload-exabgp-config]'
end

template '/etc/exabgp/neighbor-changes.rb' do
  source 'neighbor-changes.rb.erb'
  variables hubot_publish: {
              url: node[:exabgp][:hubot][:url],
              secret: node[:exabgp][:hubot][:secret],
              event: node[:exabgp][:hubot][:event]
            }
  mode 0755
  notifies :run, 'execute[reload-exabgp-config]'
end

execute 'reload-exabgp-config' do
  action :nothing
  command 'sv 2 exabgp'
end

runit_service 'exabgp' do
  default_logger true
end
