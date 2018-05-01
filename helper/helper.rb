@log_file = "/var/log/webhook_receiver.log"

###############################################################################

# Logs a message into the log file
# Params:
# +message+:: the message string to be written to the log file
def log_message(message)
  File.open(@log_file, "a") { |f|
    f.puts "#{Time.now} --- " + message
  }
end

# Deletes the existing local repo and clones the project to the same folder afterwards
# Params:
# +project+:: +Project+ object that holds the parsed configuration file for the related project
def re_clone(project, event)
  reClone = system("sudo rm -rf #{project["project_parent"]}/#{project["project_name"]}")
  if project["ssh"]
    reClone = system("sudo ssh-agent bash -c 'ssh-add #{project["ssh_key"]}; git clone -b #{event["action"]["checkout_branch"]} --single-branch #{project["project_url"]} #{project["project_parent"]}/#{project["project_name"]}'")
  else
    reClone = system("sudo git clone -b git clone -b #{event["action"]["checkout_branch"]} --single-branch #{project["project_url"]} #{project["project_parent"]}/#{project["project_name"]}")
  end
  log_message "reClone was #{reClone}"
end

# Enters the local git repo and executes the specified git strategy (e.x. 'pull')
# Params:
# +project+:: +Project+ object that holds the parsed configuration file for the related project
# +event+:: +Event+ object which is the related event from the project settings for the current webhook
def do_strategy(project, event)
  strategy = system("cd #{project["project_parent"]}/#{project["project_name"]}")
  strategy = system("git #{event["action"]["strategy"]}")
  log_message "#{event["action"]["strategy"]} was #{reClone}"
end
