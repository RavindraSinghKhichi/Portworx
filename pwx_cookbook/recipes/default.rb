#
# Cookbook:: pwx_cookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute 'make_root_shared' do
  command 'sudo mount --make-shared /'
end

docker_service 'default' do
  action [:create, :stop]
end

bash 'comment_mount_flag' do
  cwd '/'
  code <<-EOH
   sed -i 's/^MountFlags.*/#&/g' /usr/lib/systemd/system/docker.service
 EOH
end

docker_service 'default' do
  action :start
end

execute 'mkdir' do
  command 'mkdir -p /etc/pwx'
end

template '/etc/pwx/config.json' do
  action :create
  source 'config.json.erb'
  variables(
    cluster: node['pwx_cookbook']['clusterid'],
    KVDB: node['pwx_cookbook']['KVDB_url'],
    device: node['pwx_cookbook']['device-name']
  )
end

docker_image 'portworx/px-dev'

docker_container 'pwx' do
  repo 'portworx/px-dev'
  restart_policy 'always'
  network_mode 'host'
  privileged true
  volumes ['/run/docker/plugins', '/run/docker/plugins']
  volumes ['/var/lib/osd', '/var/lib/osd', 'shared']
  volumes ['/dev', '/dev']
  volumes ['/etc/pwx', '/etc/pwx']
  volumes ['/opt/pwx/bin', '/export_bin']
  volumes ['/var/run/docker.sock', '/var/run/docker.sock']
  volumes ['/var/cores', '/var/cores']
  volumes ['/usr/src', '/usr/src']
  volumes ['/lib/modules', '/lib/modules']
end

