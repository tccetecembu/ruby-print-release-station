require "./printing_report"
require "test/unit"
require "sequel"

class TestPrintingReport < Test::Unit::TestCase
  def load_sample_db
    db = Sequel.sqlite
    db.create_table :printLogs do
      primary_key :id
      String :jobTitle
      String :jobOwner
      Float :price
      DateTime :date
    end
    db
  end
  
  def test_today
    db = self.load_sample_db
    job = Utils::Job.new 1, "Impressao", "Eu"
    PrintingReport.logPrintJob db, job, 2
    job = Utils::Job.new 2, "Não é pra aparecer", "outro"
    PrintingReport.logPrintJob(db, job, 3, Date.today - 1)
    
    printLogs = db[:printLogs]
    assert_equal(printLogs.count, 2)
    first = printLogs.first
    assert_equal(first[:id], 1)
    assert_equal(first[:jobTitle], "Impressao")
    
    jobs = PrintingReport.listPrintLogsOnDay db, Date.today
    assert_equal jobs.count, 1
    assert_equal jobs.first[:id], 1
    assert_equal jobs.first[:jobTitle], "Impressao"
  end
  
  def test_single_day
    db = self.load_sample_db
    job = Utils::Job.new 1, "Impressao", "Eu"
    PrintingReport.logPrintJob db, job, 2
    job = Utils::Job.new 2, "Não é pra aparecer", "outro"
    PrintingReport.logPrintJob(db, job, 3, DateTime.now - 1)
    
    printLogs = db[:printLogs]
    assert_equal printLogs.count, 2
    jobs = PrintingReport.listPrintLogsOnDay(db, Date.today - 1)
    assert_equal jobs.count, 1
    assert_equal jobs.first[:id], 2
  end
end
    