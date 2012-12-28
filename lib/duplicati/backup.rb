class Duplicati
  class Backup
    def initialize(opts={})
      @opts = opts
    end

    def command
      %Q["#{@opts[:duplicati_path]}" backup "#{@opts[:backup_paths].join(File::PATH_SEPARATOR)}" "#{@opts[:backup_store_path]}"
             --passphrase="#{@opts[:backup_encryption_key]}"
             --auto-cleanup                        
             --full-if-older-than=1M
             --usn-policy=on
             --snapshot-policy=on
             --full-if-sourcefolder-changed
             2>&1 1>> "#{@opts[:log_path]}" &&

             "#{@opts[:duplicati_path]}" delete-all-but-n 5 "#{@opts[:backup_store_path]}"
             --force
             2>&1 1>> "#{@opts[:log_path]}"]
    end
  end
end
