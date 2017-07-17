#
# Cookbook:: pwx_cookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute 'comnet mount flag' do
  command "sed -i 's/^MountFlags.*/#&/g' /usr/lib/systemd/system/docker.service"
  only_if { 'test -f /usr/lib/systemd/system/docker.service' }
end

pwxcon 'run pwx container' do
  clusterid node['pwx_cookbook_customrs']['clusterid']
  kvdb node['pwx_cookbook_customrs']['kvdb']
  devices node['pwx_cookbook_customrs']['devices']
end
