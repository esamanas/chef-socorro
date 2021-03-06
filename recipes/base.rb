# cookbook_file "/etc/apt/sources.list" do
#   source "sources.list" 
#   owner "root"
#   group "root"
#   mode "0644"
# end

require_recipe "apt"

package "libxslt1-dev" do
  action :install
end

require_recipe "build-essential"

package "python-software-properties" do
  action :install
end

package "curl" do
  action :install
end

require_recipe "java"
require_recipe "git"
require_recipe "rsyslog"

package "libpq-dev" do
  action :install
end

require_recipe "subversion"
require_recipe "python"
require_recipe "python::virtualenv"
require_recipe "ant"

package "supervisor" do
  action :install
end

group "socorro" do
  action :create
end

user "socorro" do
  gid "admin"
  home "/home/socorro"
  shell "/bin/bash"
  uid 10000
  system true
  supports :manage_home => true
end

directory "/home/socorro/source" do
  owner "socorro"
  group "socorro"
  mode "0777"
  action :create
end

cookbook_file "/etc/hosts" do
  source "hosts" 
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/hostname" do
  source "hostname" 
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/rsyslog.conf" do
  source "rsyslog/rsyslog.conf"
  owner "root"
  group "root"
  mode 0644
end

directory "/data" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

directory "/data/socorro" do
  owner "socorro"
  group "socorro"
  mode "0755"
  action :create
end

directory "/etc/socorro" do
  owner "socorro"
  group "socorro"
  mode "0755"
  action :create
end

directory "/var/log/socorro" do
  owner "socorro"
  group "socorro"
  mode "777"
  action :create
end

directory "/home/socorro/persistent" do
  owner "socorro"
  group "socorro"
  action :create
end

git "/home/socorro/source" do
  repository "#{node['socorro']['git']['repository']}"
  reference "#{node['socorro']['git']['branch']}"
  action :sync
end

template "/home/socorro/source/scripts/config/commonconfig.py" do
  source "socorro/commonconfig.py.erb"
  mode "644"
end

link "/usr/lib/jvm/default-java" do
  to "/usr/lib/jvm/java-6-openjdk"
  link_type :symbolic 
end

ruby_block "set-env-java-home" do
  block do
    ENV["JAVA_HOME"] = "/usr/lib/jvm/default-java"
  end
end

execute "make breakpad" do
  cwd "/home/socorro/source"
  command "/usr/bin/make breakpad"
  creates "/home/socorro/source/stackwalk"
  user "root"
  action :run
end

execute "make install" do
  cwd "/home/socorro/source"
  command "/usr/bin/make install"
  creates "/data/socorro/htdocs/.htaccess"
  environment "JAVA_HOME" => "/usr/lib/jvm/default-java"
  user "root"
  action :run
end
