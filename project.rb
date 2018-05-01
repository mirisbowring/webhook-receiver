#!/usr/bin/ruby

require "json"

class Project
  def initialize(json_path)
    @data = JSON.parse File.read json_path
    @name = @data["project_name"]
  end
end