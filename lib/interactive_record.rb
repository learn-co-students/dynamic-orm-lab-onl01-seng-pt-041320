require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
   def self.table_name
     self.to_s.downcase.pluralize
   end 

   def self.column_names
     sql = "pragma table_info(#{table_name})"
     results = DB[:conn].execute(sql)
     results.map do |column|
      column["name"]
     end.compact
   end

   def initialize(attributes={})
     attributes.each do |property, value|
        send("#{property}=", value)
     end 
   end

   def self.set_attrs
     column_names.each do |col_name|
        attr_accessor col_name.to_sym
     end
   end

   def table_name_for_insert
     self.class.table_name
   end

   def col_names_for_insert
     cols = self.class.column_names
     cols.delete_if { |name| name == 'id' }.join(', ')
   end

   def values_for_insert
     self.class.column_names.map do |col_name|
        "'#{send(col_name)}'" unless send(col_name).nil?
     end.compact.join(', ')
   end
   
   def save 
     sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
     DB[:conn].execute(sql)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
   end

   def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name) 
   end

   def self.find_by(attribute)
    column_name = attribute.keys[0].to_s
    value_name = attribute.values[0]

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{column_name} = ?
      SQL

    DB[:conn].execute(sql, value_name);
  end
end