#!/usr/bin/env ruby

require "sinatra"
load "utils.rb"
require "yaml"

config = YAML::load_file("./config.yaml")

use Rack::Auth::Basic do |username, password|
    [username, password] == [config["username"], config["password"]]
end

get '/api/list' do
    Utils.getJobs(config["printer_name"]).to_json
end

get '/api/resume/all' do
    Utils.getJobs(config["printer_name"]).each { |job| job.resume }
end

get '/api/resume/:jobid' do |jobid|
    job = Utils.getJobs(config["printer_name"]).find { |x| x.id == jobid.to_i }
    return "0" if job.nil?
    job.resume
    return "1"
end

get '/api/cancel/all' do
    Utils.getJobs(config["printer_name"]).each { |job| job.cancel }
end

get '/api/cancel/:jobid' do |jobid|
    job = Utils.getJobs(config["printer_name"]).find { |x| x.id == jobid.to_i }
    return "0" if job.nil?
    job.cancel
    return "1"
end

get '/api/price/page' do
  "#{config["price_per_page"]}"
end

get '/api/price/print' do
  "#{config["price_per_print"]}"
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end
