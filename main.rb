#!/usr/bin/env ruby

require "sinatra"
require_relative "utils"
require_relative "printing_report"
require "yaml"
require "sequel"
require "pathname"

$config = YAML::load_file("./config.yaml")

DB = Sequel.sqlite $config["database"]
$cachedJobs = []

def updateJobs
    newJobs = Utils.getJobs $config["printer_name"]
    $cachedJobs.keep_if {|job| newJobs.include? job }
    $cachedJobs = $cachedJobs + ($newJobs - $cachedJobs)
end

use Rack::Auth::Basic do |username, password|
    [username, password] == [$config["username"], $config["password"]]
end

get '/api/list' do
    updateJobs
    $cachedJobs.to_json
end

get '/api/resume/all' do
    updateJobs
    $cachedJobs.each { |job|
      job.resume
      PrintingReport.logPrintJob DB, job, (job.pageCount * $config["price_per_page"] + $config["price_per_print"]) if $config["log_printing"]
    }
end

get '/api/resume/:jobid' do |jobid|
    updateJobs
    job = $cachedJobs.find { |x| x.id == jobid.to_i }
    return "0" if job.nil?
    job.resume
    # Deviamos guardar no BD agora, no resume do job, em outro momento? Só Deus sabe.
    PrintingReport.logPrintJob DB, job, (job.pageCount * $config["price_per_page"] + $config["price_per_print"]) if $config["log_printing"]
    return "1"
end

get '/api/cancel/all' do
    updateJobs
    $cachedJobs.each { |job| job.cancel }
end

get '/api/cancel/:jobid' do |jobid|
    updateJobs
    job = $cachedJobs.find { |x| x.id == jobid.to_i }
    return "0" if job.nil?
    job.cancel
    return "1"
end

get '/api/price/page' do
  "#{$config["price_per_page"]}"
end

get '/api/price/print' do
  "#{$config["price_per_print"]}"
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

get '/api/images/getRandomBackground' do
  picture = (Dir.glob(File.join settings.public_folder, 'images/*.png') + Dir.glob(File.join settings.public_folder, 'images/*.jpg')).shuffle.sample
  Pathname.new(picture).relative_path_from(Pathname.new settings.public_folder).to_s
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/logs' do
  send_file File.join(settings.public_folder, 'logs.html')
end
