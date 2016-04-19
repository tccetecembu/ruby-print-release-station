require "utils"
require "date"

module PrintingReport
  def logPrintJob(db, job, totalPrice)
    printLogs = db[:printLogs]
    printLogs.insert(:jobTitle => job.title, :jobOwner => job.owner, :price => totalPrice, :date => DateTime.now)
  end
  
  def listPrintLogs
    printLogs = db[:printLogs]
    printLogs.all
  end
  
  def listPrintLogsBetween(start, end_)
    printLogs = db[:printLogs]
    printLogs.where("date > ? AND date < ?", start, end_).all
  end
  
  def listPrintJobsOnDay(day)
    listPrintJobsBetween(day, day + 1)
  end
end