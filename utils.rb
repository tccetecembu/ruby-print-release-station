require "json"
require "cupsffi"
require "tempfile"

module Utils
    def Utils.getSpoolPath()
        # Será que isso muda?
        return "/var/spool/cups"
    end    
    
    def Utils.getJobFilename(jobId)
        # Segundo o IBquota, o arquivo do job fica em /var/spool/cups, com o nome "d00xxx-001", onde xxx é o número do job
        return sprintf "d%05d-001", jobId
    end
    
    def Utils.getJobPageCount(jobPath)
        # Aparentemente o pkpgcounter não se dá muito bem com arquivos comprimidos, então checar se o arquivo no spooler
        compressed = `file #{jobPath} | grep gzip` != ""
        if compressed
            tmpFile = Tempfile.new "rprs"
            `gunzip < #{jobPath} > #{tmpFile.path}`
            ret = `pkpgcounter #{tmpFile.path}`
            tmpFile.unlink
            return ret
        end
        
        return `pkpgcounter #{jobPath}`
    end

    class Job
        attr_accessor :id, :title, :owner
        
        def self.new_from_string(line)
            args = line.split " "
            # args[3..-3].join se baseia no fato da linha ter a parte "active user titulo com espaco x bytes", o -3 pega até o "espaco"
            return self.new(args[2].to_i, args[3..-3].join(" "), args[1])
        end
        
        def self.new_from_cupsffi_job(jobObject)
            self.new(jobObject[:id], jobObject[:title].force_encoding("utf-8"), jobObject[:user].force_encoding("utf-8"))
        end
        
        def initialize(id, title = "", owner = "")
            @id = id
            @title = title
            @owner = owner
        end
        
        def jobPath
            return File.join(Utils.getSpoolPath, Utils.getJobFilename(@id))
        end
        
        def pageCount
            return Utils.getJobPageCount(self.jobPath).to_i
        end
        
        def to_json(options = {})
            return {'id' => @id, 'title' => @title, 'owner' => @owner, 'pageCount' => self.pageCount}.to_json options
        end
        
        def resume(printerName = nil)
            if printerName.nil?
                `lp -i #{@id} -H resume`
            else
                `lp -d #{printerName} -i #{@id} -H resume`
            end
        end
        
        def cancel(printerName = nil)
            if printerName.nil?
                `lprm #{@id}`
            else
                `lprm -P #{printerName} #{@id}`
            end
        end
    end
    
    def Utils.getJobsFromCupsffiPrinter(printer)
        return printer.get_all_jobs.map { |x| Job.new_from_cupsffi_job x }
    end
    
    def Utils.getJobs(printerName)
        Utils.getJobsFromCupsffiPrinter(CupsPrinter.new printerName)
    end
end
