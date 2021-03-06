require "webrick"
require "json"

require_relative "helper/event"
require_relative "helper/project"
require_relative "helper/helper"

@port = 8000

### Project configuration path
@config_path = "/opt/scripts/gitlab/webhook_receiver/config/"

###############################################################################

# Loads the webhook configurations
def load_config
  projects = Array.new
  Dir.glob("#{@config_path}/*.json") do |cf|
    if !cf.end_with?("template.json")
      projects << Project.new(cf)
    end
  end
  projects
end

# Parses the webhook and handles the configured events
# Params:
# +request+:: +JSON+ object that holds the webhook data
def parse_request(request)
  projects = load_config
  project = projects.select { |proj| proj.name == request["project"]["name"] }
  if project.length < 1
    log_message "Project '#{request["project"]["name"]}' not found in configuration."
    return
  end
  project = project[0]
  begin
    event = Event.new project.data["events"].detect { |e| e["event"] == request["object_kind"] }
    if !event.exist?
      log_message "Event '#{request["object_kind"]}' not configured for #{project.name}."
    elsif event.check_requirements request # returns true if valid
      log_message "Request valid!"
      log_message request
      event.handle_action project
    else
      log_message "The Current Request does not match all requirements. - skipping"
    end
  rescue StandardError => e
    log_message "An error occured: #{e}"
    log_message e.backtrace
  end
end

private :load_config, :parse_request

log_message "<-- Starting webhook_receiver -->"
log_message "Reading configuration files"
load_config
log_message "Starting HTTPServer on port #{@port}"
server = WEBrick::HTTPServer.new :Port => @port
server.mount_proc "/" do |req, res|
  log_message "Received new request"
  parse_request JSON.parse req.body
end

trap "INT" do
  server.shutdown
end

trap "TERM" do
  server.shutdown
end

server.start
