class Duplicati
  class Clean < Command
    def command
      %Q["#{@duplicati_path}" delete-all-but-n 5 "#{@backup_store_path}"
             #{encryption_option}
             --force
             1>>"#{@log_path}"
             2>&1]
    end
  end
end
