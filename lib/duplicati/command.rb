class Duplicati
  class Command

    def initialize(opts)
      @duplicati_path = opts[:duplicati_path]
      @backup_store_path = opts[:backup_store_path] or raise ":backup_store_path option is missing!"
      @backup_encryption_key = opts[:backup_encryption_key]
      @log_path = opts[:log_path]
    end

    private

    def encryption_option
      @backup_encryption_key ? 
        %Q[--passphrase="#{@backup_encryption_key}"] :
        %Q[--no-encryption]
    end    
  end
end
