docker-apps Cookbook
====================

Chef lwrp for run Docker containers


```ruby

directory "/opt/data/postgres" do
  mode 0700
  recursive true
end

docker_app_instance "postgres" do
  image "prepor/postgres"
  ports ["5432"]
  port_bindings "5432/tcp" => [{"HostIp" => "0.0.0.0", "HostPort" => "5432"}]
  volumes ["/opt/data/postgres/:/var/lib/postgresql/9.3/main"]
end

```
