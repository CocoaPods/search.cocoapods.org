ENV['DATABASE_URL'] ||= "postgres://localhost/trunk_cocoapods_org_#{ENV['RACK_ENV']}"
DB = Sequel.connect ENV['DATABASE_URL']

require File.expand_path '../models/pod', __FILE__