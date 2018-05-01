require "json"

class Project

  # Initializes this object
  # Params:
  # +json_path+:: a tring that hold the path to a specific configuration file in json format
  def initialize(json_path)
    @data = JSON.parse File.read json_path
    @name = @data["project_name"]
  end

  # Returns the data JSON object
  def data
    @data
  end

  # Returns the project's name of this object
  def name
    @name
  end
end
