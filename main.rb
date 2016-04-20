#!/usr/bin/env ruby

require "sinatra"
require_relative "utils"
require_relative "printing_report"
require "yaml"
require "sequel"

config = YAML::load_file("./config.yaml")

DB = Sequel.sqlite config["database"]

use Rack::Auth::Basic do |username, password|
    [username, password] == [config["username"], config["password"]]
end

get '/api/list' do
    Utils.getJobs(config["printer_name"]).to_json
end

get '/api/resume/all' do
    Utils.getJobs(config["printer_name"]).each { |job|
      job.resume
      PrintingReport.logPrintJob DB, job, (job.pageCount * config["price_per_page"] + config["price_per_print"])
    }
end

get '/api/resume/:jobid' do |jobid|
    job = Utils.getJobs(config["printer_name"]).find { |x| x.id == jobid.to_i }
    return "0" if job.nil?
    job.resume
    # Deviamos guardar no BD agora, no resume do job, em outro momento? Só Deus sabe.
    PrintingReport.logPrintJob DB, job, (job.pageCount * config["price_per_page"] + config["price_per_print"])
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

get '/api/logs/all' do
  PrintingReport.listPrintLogs(DB).to_json
end

get '/api/logs/today' do
  PrintingReport.listPrintLogsOnDay(DB, Date.today).to_json
end

get '/api/logs/day/:year/:month/:day' do |year, month, day| 
  year = year.to_i
  month = month.to_i
  day = day.to_i
  
  PrintingReport.listPrintLogsOnDay(DB, Date.new(year, month, day)).to_json
end

get '/api/logs/daysRange/:startYear/:startMonth/:startDay/:endYear/:endMonth/:endDay' do |startYear, startMonth, startDay, endYear, endMonth, endDay|
  # Isso é horrivel.
  startYear, startMonth, startDay, endYear, endMonth, endDay = [startYear, startMonth, startDay, endYear, endMonth, endDay].map { |i| i.to_i }
  
  startDate = Date.new startYear, startMonth, startDay
  endDate = Date.new endYear, endMonth, endDay
  
  # É preciso adicionar um dia para listar os trabalhos que aconteceram naquele dia, até 23:59:59.
  PrintingReport.listPrintLogsBetween(DB, startDate, endDate + 1).to_json
end 

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/logs' do
  send_file File.join(settings.public_folder, 'logs.html')
end
