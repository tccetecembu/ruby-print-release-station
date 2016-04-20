require_relative "utils"
require "date"

module PrintingReport
  def PrintingReport.logPrintJob(db, job, totalPrice, date = DateTime.now)
    printLogs = db[:printLogs]
    printLogs.insert(:jobTitle => job.title, :jobOwner => job.owner, :price => totalPrice, :date => date)
  end
  
  def PrintingReport.listPrintLogs(db)
    printLogs = db[:printLogs]
    printLogs.all
  end
  
  def PrintingReport.listPrintLogsBetween(db, start, end_)
    printLogs = db[:printLogs]
    printLogs.where("date > ? AND date < ?", start, end_).all
  end
  
  def PrintingReport.listPrintLogsOnDay(db, day)
    PrintingReport.listPrintLogsBetween(db, day, day + 1)
  end
end