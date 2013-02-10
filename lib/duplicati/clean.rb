class Duplicati
  class Clean
    def initialize(opts)
      @duplicati_path = opts[:duplicati_path]
      @backup_store_path = opts[:backup_store_path] or raise ":backup_store_path option is missing for clean!"
      @backup_encryption_key = opts[:backup_encryption_key]
      @log_path = opts[:log_path]
    end

    def command
      %Q["#{@duplicati_path}" delete-all-but-n 5 "#{@backup_store_path}"
             #{encryption_option}
             --force
             2>&1 1>> "#{@log_path}"]
    end

    private

    def encryption_option
      %Q[--passphrase="#{@backup_encryption_key}"] if @backup_encryption_key
    end

  end
end
