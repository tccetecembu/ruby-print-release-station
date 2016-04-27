# Conjunto de funções relacionadas a leitura de trabalhos do CUPS.
# Provavelmente devia ter um melhor nome.
# 
# Author:: Ramon Dantas
# License:: MIT

require "json"
require "cupsffi"
require "tempfile"

module Utils
    # Retorna a localização do spool do CUPS.
    # * *Returns* :
    #   - O caminho do spool do CUPS.
    def Utils.getSpoolPath()
        # Será que isso muda?
        return "/var/spool/cups"
    end
    
    # Retorna o nome do arquivo a ser imprimido para um trabalho do CUPS
    # * *Args*  :
    #   - +jobId+ -> ID do trabalho do CUPS
    # * *Returns* :
    #   - O nome do arquivo do trabalho.
    def Utils.getJobFilename(jobId)
        # Segundo o IBquota, o arquivo do job fica em /var/spool/cups, com o nome "d00xxx-001", onde xxx é o número do job
        return sprintf "d%05d-001", jobId
    end
    
    # Calcula o número de páginas para um arquivo a ser imprimido
    # * *Args*  :
    #   - +jobPath+ -> Caminho completo do arquivo a ser imprimido, localizado dentro do spool do CUPS.
    # * *Returns* :
    #   - O número de páginas a serem impressas.
    def Utils.getJobPageCount(jobPath)
        # Aparentemente o pkpgcounter não se dá muito bem com arquivos comprimidos, então checar se o arquivo no spooler
        # TODO Refatorar isso para uma função separada
        compressed = `file #{jobPath} | grep gzip` != ""
        if compressed
            tmpFile = Tempfile.new "rprs"
            `gunzip < #{jobPath} > #{tmpFile.path}`
            ret = `pkpgcounter #{tmpFile.path}`
            tmpFile.unlink
            return ret
        end
        
        `pkpgcounter #{jobPath}`.to_i
    end
    
    # Calcula o número de páginas coloridas em um trabalho a ser impresso
    # * *Args*  ;
    #   - +jobPath+ -> Caminho completo do trabalho a ser impresso, se localiza dentro do spool do CUPS.
    # * *Returns* :
    #   - O número de paginas coloridas a serem impressas
    def Utils.getJobColorPageCount(jobPath)
        re = /^\W*G\W+:\W+(?<grayscale>[\d.]+)%\W+C\W:\W+(?<color>[\d.]+)%$/
               
        # TODO Refatorar isso para uma função separada
        compressed = `file #{jobPath} | grep gzip` != ""
        if compressed
            tmpFile = Tempfile.new "rprs"
            `gunzip < #{jobPath} > #{tmpFile.path}`
            out = `pkpgcounter -c GC #{tmpFile.path}`
            tmpFile.unlink
            return out.scan(re).count { |grayscale, color| color.to_f > 1 }
        end
        
        out = `pkpgcounter -c GC #{jobPath}`
        
        out.scan(re).count { |grayscale, color| color.to_f > 1 }
    end

    # Essa classe representa um trabalho de impressão, e as funções necessárias para a sua manipulação.
    # Deve ser usada, ao invés de usar diretamente as funções relacionadas aos trabalhos, como +getJobFilename+ e +getJobPageCount+.
    class Job
        attr_accessor :id, :title, :owner
        
        # Cria um novo Job, baseado numa linha da saída do comando lpq -P (nome da impressora)
        # * *Args*  :
        #   - +line+ -> A linha do comando lpq.
        # * *Returns* :
        #   - Um novo objeto Job
        def self.new_from_string(line)
            args = line.split " "
            # args[3..-3].join se baseia no fato da linha ter a parte "active user titulo com espaco x bytes", o -3 pega até o "espaco"
            return self.new(args[2].to_i, args[3..-3].join(" "), args[1])
        end
        
        # Cria um novo Job, baseado em um objeto de Job da biblioteca cupsffi
        # * *Args*  :
        #   - +jobObject+ -> O objeto de Job do cupsffi
        # * *Returns* :
        #   - Um novo objeto Job
        def self.new_from_cupsffi_job(jobObject)
            self.new(jobObject[:id], jobObject[:title].force_encoding("utf-8"), jobObject[:user].force_encoding("utf-8"))
        end
    
        def initialize(id, title = "", owner = "")
            @id = id
            @title = title
            @owner = owner
        end
        
        def ==(o)
            o.class == self.class && o.id == @id
        end
        
        def eql?(o)
            self.==(o)
        end
        
        # Usar outras coisas como hash seria bom, talvez.
        def hash
            @id
        end
        
        # O caminho para o arquivo a ser impresso pelo CUPS.
        def jobPath
            @jobPath ||= File.join(Utils.getSpoolPath, Utils.getJobFilename(@id))
        end
        
        # O número de páginas a ser impresso por este trabalho.
        def pageCount
            @pageCount ||= Utils.getJobPageCount(self.jobPath)
        end
        
        def colorPages
            @colorPages ||= Utils.getJobColorPageCount(self.jobPath)
        end
        
        def grayscalePages
            self.pageCount - self.colorPages
        end
        
        # Converte esse trabalho para o formato JSON.
        def to_json(options = {})
            return {'id' => @id, 'title' => @title, 'owner' => @owner, 'pageCount' => self.pageCount, 'colorPages' => self.colorPages}.to_json options
        end
        
        # Continua o trabalho de impressão.
        def resume(printerName = nil)
            if printerName.nil?
                `lp -i #{@id} -H resume`
            else
                `lp -d #{printerName} -i #{@id} -H resume`
            end
        end
        
        # Cancela o trabalho de impressão.
        def cancel(printerName = nil)
            if printerName.nil?
                `lprm #{@id}`
            else
                `lprm -P #{printerName} #{@id}`
            end
        end
    end
    
    # Lê os trabalhos de um objeto de impressora do CupsFFI.
    # * *Args*  :
    #   - +printer+ -> O objeto de impressora.
    # * *Returns* :
    #   - Uma array de objetos Job
    def Utils.getJobsFromCupsffiPrinter(printer)
        return printer.get_all_jobs.map { |x| Job.new_from_cupsffi_job x }
    end
    
    # Lê os trabalho de uma impressora
    # * *Args*  :
    #   - +printerName+ -> Uma string como nome da impressora.
    # * *Returns* :
    #   - Uma array de objetos Job
    def Utils.getJobs(printerName)
        Utils.getJobsFromCupsffiPrinter(CupsPrinter.new printerName)
    end
end
