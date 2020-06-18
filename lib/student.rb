require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  # atttr_accessor :id, :name, :grade
  set_attrs
end
