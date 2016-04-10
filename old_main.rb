#!/usr/bin/env ruby

load "utils.rb"

PRINTER = "Deskjet_5520"

pausedJobs = []
loop do
    jobsString = `lpq -P #{PRINTER} | tail -n +3 | awk '{print $3}'`
    jobIds = jobsString.split "\n"
    jobIds.each { |id|
        if not pausedJobs.include? id
            puts "Got job #{id}"
            `lp -d #{PRINTER} -i #{id} -H hold`
            pausedJobs << id
            
            pageCount = Utils.getJobPageCount(Utils.getSpoolPath() + "/" + Utils.getJobFilename(id))
            puts "Page count for job #{id} is #{pageCount}"
        end
    }
    sleep 0.2
end

