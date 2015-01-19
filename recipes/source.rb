include_recipe 'mercurial'

mercurial '/usr/src/exabgp' do
  repository 'https://code.google.com/p/exabgp/'
  reference node[:exabgp][:source_version]
  action :sync
end

node.set[:exabgp][:bin_path] = '/usr/src/exabgp/sbin/exabgp'

include_recipe 'exabgp'