resource_name :pwxcon
property :name, String, name_property: true
property :clusterid, String, required: true
property :mgtiface, String
property :dataiface, String
property :kvdb, String, required: true
property :loginurl, String
property :devices, String
property :storage, [Array, Hash]
property :debug_level, String
property :device_md, Array

action :create do
  execute 'mkdir' do
    command 'mkdir -p /etc/pwx'
  end

  template '/etc/pwx/config.json' do
    source 'config.json.erb'
    variables(
      clusterid: new_resource.clusterid,
      mgtiface: new_resource.mgtiface,
      dataiface: new_resource.dataiface,
      kvdb: new_resource.kvdb,
      loginurl: new_resource.loginurl,
      devices: new_resource.devices,
      debug_level: new_resource.debug_level,
      device_md: new_resource.device_md
    )
  end

  execute 'make_root_shared' do
    command 'sudo mount --make-shared /'
  end

  docker_service 'default' do
    action :create
  end

  docker_service 'default' do
    action :start
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
end

action :delete do
  docker_container '#{new_resource.name}' do
    remove_volumes true
    action :delete
  end
end
