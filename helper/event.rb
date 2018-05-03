require_relative "helper"

class Event

  # Initializes the object
  # Params:
  # +event+:: a parsed JSON object that contains the event that should be handled
  def initialize(event)
    @event = event
  end

  # Compares a required keypair from the event attribute with the request keypair.
  # Returns true if the are equal and false if not.
  def equal_pair(key, request)
    if @event["required"][key] == request["object_attributes"][key] || event["required"][key] == ""
      true
    else
      false
    end
  end

  # Verifies that the request matches the requirements that are specified in the config json
  # Params:
  # +request+:: +JSON+ object that holds the request body
  def check_requirements(request)
    valid = true
    keys = @event["required"].keys
    keys.each { |k| valid = equal_pair(k, request) if valid != false }
    valid
  end

  # Handles the specified actions after the requirements have been verified
  # Params:
  # +project+:: +Project+ object that holds the parsed configuration file for the related project
  def handle_action(project)
    puts "1"
    puts @event
    puts @event["action"]
    puts @event["action"]["strategy"]
    if @event["action"]["strategy"] == "clone"
      puts "1.5"
      re_clone(project, @event)
    else
      do_strategy(project, @event)
    end
    puts "2"
    returnVal = ""
    begin
      returnVal = system(@event["action"]["execute"])
    rescue
      log_message "The command <#{@event["action"]["execute"]}> could not be executed!"
      log_message returnVal
    end
  end

  # Checks if this object exist / is not empty
  def exist?
    !(@event.nil? || @event.empty?)
  end

  # returns the event attribute
  def event
    @event
  end
end
