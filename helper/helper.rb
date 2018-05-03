@log_file = "/var/log/webhook_receiver.log"

###############################################################################

# Logs a message into the log file
# Params:
# +message+:: the message string to be written to the log file
def log_message(message)
  puts message
  File.open(@log_file, "a") { |f|
    f.puts "#{Time.now} --- #{message.to_s}"
  }
  puts "written message"
end

# Deletes the existing local repo and clones the project to the same folder afterwards
# Params:
# +project+:: +Project+ object that holds the parsed configuration file for the related project
def re_clone(project, event)
  log_message "Recloning #{project.name}"
  reClone = system("sudo rm -rf #{project.data["project_parent"]}/#{project.data["project_name"]}")
  log_message "Deleted old files"
  log_message "ssh enabled: #{project.data["ssh"]}"
  if project.data["ssh"]
    reClone = system("sudo ssh-agent bash -c 'ssh-add #{project.data["ssh_key"]}; git clone -b #{event["action"]["checkout_branch"]} --single-branch #{project.data["project_url"]} #{project.data["project_parent"]}/#{project.data["project_name"]}'")
  else
    reClone = system("sudo git clone -b git clone -b #{event["action"]["checkout_branch"]} --single-branch #{project.data["project_url"]} #{project.data["project_parent"]}/#{project.data["project_name"]}")
  end
  log_message "reClone was #{reClone}"
end

# Enters the local git repo and executes the specified git strategy (e.x. 'pull')
# Params:
# +project+:: +Project+ object that holds the parsed configuration file for the related project
# +event+:: +Event+ object which is the related event from the project settings for the current webhook
def do_strategy(project, event)
  strategy = system("cd #{project.data["project_parent"]}/#{project.data["project_name"]}")
  strategy = system("git #{event.data["action"]["strategy"]}")
  log_message "#{event["action"]["strategy"]} was #{reClone}"
end
