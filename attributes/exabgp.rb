default[:exabgp][:local_as] = 12345
default[:exabgp][:peer_as] = 12345
default[:exabgp][:community] = [0]

default[:exabgp][:hold_time] = 20
default[:exabgp][:local_preference] = nil

default[:exabgp][:ipv4][:neighbor] = '127.0.0.1'
default[:exabgp][:ipv4][:anycast] = ['127.0.0.1/32', '127.0.0.2/32']
default[:exabgp][:ipv4][:enable_static_route] = true

default[:exabgp][:ipv6][:neighbor] = nil
default[:exabgp][:ipv6][:anycast] = ['::1/128']

default[:exabgp][:source_version] = 'master'
default[:exabgp][:bin_path] = '/usr/local/bin/exabgp'

default[:exabgp][:watchdog_flag_file] = '/tmp/exabgp-announce'

default[:exabgp][:hubot][:enable] = false
default[:exabgp][:hubot][:url] = 'http://localhost:9998'
default[:exabgp][:hubot][:secret] = 'secret'
default[:exabgp][:hubot][:event] = 'sre'

default[:exabgp][:systemd][:after] = %w(network.target)

# lock pip version, poise-python is broken with later
# https://github.com/vinted/chef/blob/c5af12a421fefbc55e60240329e014f1d7f4a690/cookbooks/vinted-python/attributes/default.rb#L3
default['poise-python']['options']['pip_version'] = '9.0.3'
