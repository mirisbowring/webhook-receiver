require "webrick"
require "json"

require_relative "event"
require_relative "project"
require_relative "helper"

@port = 8000

### Project configuration path
@config_path = "config/"

###############################################################################

# Loads the webhook configurations
def load_config
  @projects = Array.new
  Dir.glob("#{@config_path}/*.json") do |cf|
    if !cf.end_with?("template.json")
      @projects << Project.new(cf)
    end
  end
end

# Parses the webhook and handles the configured events
# Params:
# +request+:: +JSON+ object that holds the webhook data
def parse_request(request)
  project = @projects.select { |proj| proj.name == request["project"]["name"] }
  begin
    data = project[0].data
    event = Event.new data["events"].detect { |e| e["event"] == request["object_kind"] }
    if !event.exist?
      log_message "Event '#{request["object_kind"]}' not configured for #{project.name}."
    elsif event.check_requirements request # returns true if valid
      event.handle_action project
    end
  rescue
    log_message "Project '#{request["project"]["name"]}' not found in configuration."
  end
end

private :load_config, :parse_request

log_message "<-- Starting webhook_receiver -->"
log_message "Reading configuration files"
load_config
parse_request JSON.parse File.read "test.json"
log_message "Starting HTTPServer on port #{@port}"
server = WEBrick::HTTPServer.new :Port => @port
server.mount_proc "/" do |req, res|
  log_message "#######################################################################"
  log_message "Received new request"
  log_message req.body
  request = JSON.parse req.body
  parse_request(request)
end

trap "INT" do
  server.shutdown
end

trap "TERM" do
  server.shutdown
end

server.start
