# Contém funcionalidade relacionada aos relatórios de impressão
# A conexão com o banco de dados é efetuada dentro do programa principal, o main.rb.
# Author:: Ramon Dantas
# License:: MIT

require_relative "utils"
require "date"

module PrintingReport
    # Armazena o log de um trabalho de impressão no banco de dados
    # * *Args*  :
    #   - +db+ -> O banco de dados Sequel.
    #   - +job+ -> O objeto Utils::Job
    #   - +totalPrice+ -> O preço total, em reais (Float)
    #   - +date+ -> O horário da impressão (padrão é DateTime.now)    
    def PrintingReport.logPrintJob(db, job, totalPrice, date = DateTime.now)
        printLogs = db[:printLogs]
        printLogs.insert(:jobTitle => job.title, :jobOwner => job.owner, :price => totalPrice, :date => date)
    end
    
    # Lista os logs de impressão
    # * *Args*  :
    #   - +db+ -> O banco de dados Sequel.
    # * *Returns* :
    #   - Uma Array de hashes com os logs de impressão.
    def PrintingReport.listPrintLogs(db)
        printLogs = db[:printLogs]
        printLogs.all
    end
    
    # Lista os logs de impressão entre um período de tempo.
    # * *Args*  :
    #   - +db+ -> O banco de dados Sequel.
    #   - +start+ -> O início do período (Date)
    #   - +end+ -> O fim do período (Date)
    # * *Returns* :
    #   - Uma Array de hashes com os logs de impressão.
    def PrintingReport.listPrintLogsBetween(db, start, end_)
        printLogs = db[:printLogs]
        printLogs.where("date > ? AND date < ?", start, end_).all
    end
  
    # Lista os logs de impressão ocorridos em um dia.
    # * *Args*  :
    #   - +db+ -> O banco de dados Sequel.
    #   - +day+ -> O dia (Date)
    # * *Returns* :
    #   - Uma Array de hashes com os logs de impressão.
    def PrintingReport.listPrintLogsOnDay(db, day)
        PrintingReport.listPrintLogsBetween(db, day, day + 1)
    end
end