require "json"
require_relative "helper/event"

class TestClass
  def initialize(name)
    @name = name
  end

  def name
    @name
  end
end

my_array = Array.new

my_array << TestClass.new("1")
my_array << TestClass.new("2")
my_array << TestClass.new("3")

# puts my_array.map(&:name).include? "0"

jsonString = JSON.parse File.read "config/Webtechnologien.json"
puts jsonString["project_name"]
event = jsonString["events"].detect { |e| e["event"] == "merge_request" }
testVar = event["required"].values
puts testVar
# puts jsonString["events"]
var = ""
