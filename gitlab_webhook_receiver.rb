#!/usr/bin/ruby

require "webrick"
require "json"

# Configurations

@log_file = "/var/log/webhook_receiver.log"

@port = 8000

@project_name = "Webtechnologien"
@project_parent = "/var/www/"
@ssh_key_path = "/home/gitlab/.ssh/id_rsa_deploy"
@checkout_branch = "developing"
@git_url = "git@gitlab.zeus-coding.de:HfTL_Projects/Webtechnologien.git"
@git_event = "merge_request"
@git_event_status = "merged"

#########################################################################

def log_message(message)
  File.open(@log_file, "a") { |f|
    f.puts "#{Time.now} --- " + message
  }
end

def reclone(project)
  reClone = system("sudo rm -rf #{@project_parent}/#{@project_name}")
  reClone = system("sudo ssh-agent bash -c 'ssh-add #{@ssh_key_path}; git clone -b #{@checkout_branch} --single-branch #{@git_url} #{@project_parent}/#{@project_name}'")
  log_message "reClone was #{reClone}"
end

private :log_message, :reclone

server = WEBrick::HTTPServer.new :Port => @port
server.mount_proc "/" do |req, res|
  log_message "#######################################################################"
  log_message "Received new request"
  log_message req.body
  request = JSON.parse req.body
  if request["object_kind"] == @git_event && request["project"]["name"] == @project_name && request["object_attributes"]["target_branch"] == @checkout_branch && request["object_attributes"]["state"] == @git_event_status
    log_message "valid request"
    reclone @project_name
  end
end

trap "INT" do
  server.shutdown
end
server.start
