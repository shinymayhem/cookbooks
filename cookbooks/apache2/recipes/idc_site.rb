#
# Cookbook Name:: apache2
# Recipe:: idc_site
include_recipe "users::developers"

package "php-xml" do
    action :install
end                                                                                                                                                                                                               

app_dir = "/var/www/html/idc"

#should be created by web_app resource
#directory "#{app_dir}" do
#	owner "apache"
#	group "developers"
#	mode "0755"
#	action :create
#end

# disable default site
apache_site "default" do
    enable false
end

#add site vhost
web_app "idc-site" do
    server_name "*"
    server_aliases [ node['hostname'], node['dqdn'],  "imagodeicollege.com", "imagodeicollege.shinymayhem.com"]
    docroot "#{app_dir}/public"
    directory_index "index.php"
end

#directory "/opt/deploy" do
#    owner "root"
#    group "root"
#    mode "0755"
#    action :create 
#end
#
#cookbook_file "git_wrapper.sh" do
#    path "/opt/deploy/git_wrapper.sh"
#    owner "root"
#    group "root"
#    mode "0755"
#end
#
#cookbook_file "tzmm-processing-deploy.pem" do
#    path "/opt/deploy/tzmm-processing-deploy.pem"
#    owner "root"
#    group "root"
#    mode "0600"
#end

package "git" do
    action :install
end


#branch_name = node.chef_environment
#git "#{app_dir}" do
#    repository "git@github.com:reesew/tzmm-processing.git"
#    ssh_wrapper "/opt/deploy/git_wrapper.sh"
#    #revision "HEAD"
#    revision branch_name
#    branch_name = node.chef_environment
#    if node.chef_environment == "production" or node.chef_environment == "staging" or node.chef_environment == "testing"
#        action [:checkout, :sync]
#    elsif node.chef_environment == "development" and not File.exists?("#{app_dir}/.git/config")
#        action :checkout
#    else    
#        action :nothing
#    end
#end

#package "svn" do #required for composer hamcrest
#    if node.chef_environment == "development" or node.chef_environment == "testing"
#        action :install
#    else    
#        action :nothing
#    end
#end

#execute "composer" do
#	if File.exists?("#{app_dir}/composer.phar")
#		puts("exists")
#		command "cd #{app_dir}/; php composer.phar update"
#	end
#end

execute "own" do
    command "chown -R --from root:root root:developers #{app_dir}"
end

execute "apache-own" do #if directories exist, have apache be the owner for writing logs, etc
    command "if [ -r #{app_dir}/logs ]; then
     chown -R apache:developers #{app_dir}/logs; 
    fi 
    if [ -r #{app_dir}/logs ]; then
        chown -R apache:developers #{app_dir}/data
    fi "
end


execute "writeable" do #writeable to developers group
    command "find #{app_dir} -group developers | xargs chmod g+w"
end