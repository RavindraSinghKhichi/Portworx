include_recipe 'docker'
docker_container 'hello-world' do
  command '/hello'
  action :create
end
