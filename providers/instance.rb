def load_current_resource
  @current_resource = Chef::Resource::DockerAppInstance.new(new_resource)
  @current_container = detect_container new_resource.id
  @current_resource.running = !!@current_container
  @current_resource.up_to_date = @current_resource.running && up_to_date?
  @current_resource
end

action :run do
  if not @current_resource.running
    check_image
    create_container
  elsif not @current_resource.up_to_date
    update_container
  else
    Chef::Log.info "#{@current_resource} already run"
  end
end

def env_id(id)
  "CHEF_DOCKER_APP_NAME=#{id}"
end

def detect_container(id) 
  containers = Docker::Container.all
  env_id = env_id(id)
  containers.detect do |c|
    c.json['Config']['Env'].include?(env_id)
  end
end

def check_image
  Docker::Image.create('fromImage' => new_resource.image)
end

def up_to_date?
  fresh_image = check_image
  fresh_image.json['id'] == @current_container.json['Image']
end

def create_container
  env = new_resource.env + [env_id(new_resource.id)]
  volumes = new_resource.volumes.each_with_object({}) { |s, o| o[s.split(':')[1]] = {} }
  config = {
    'Image' => new_resource.image, 
    'Host' => new_resource.host,
    'Cmd' => new_resource.cmd,
    'User' => new_resource.user,
    'PortSpecs' => new_resource.ports,
    'Env' => env,
    'Volumes' => volumes,
    'Privileged' => new_resource.privileged
  }
  Chef::Log.debug("Creating container with config #{config}")
  lxc_conf = new_resource.lxc_conf.map { |k, v| { "Key" => k, "Value" => v } }
  container = Docker::Container.create(config).start("Binds" => new_resource.volumes, "LxcConf" => lxc_conf, "PortBindings" => new_resource.port_bindings )
  new_resource.updated_by_last_action(true)
  container
end

def update_container
  @current_container.stop
  create_container
end
