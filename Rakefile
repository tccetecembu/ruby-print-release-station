require "rake"

require "sequel"
require "yaml"

namespace :db do
  task :create do
    config = YAML::load_file("config.yaml")
    
    DB = Sequel.sqlite config["database"]
    DB.create_table :printLogs do 
      primary_key :id
      String :jobTitle
      String :jobOwner
      Float :price
      DateTime :date
    end
  end
end