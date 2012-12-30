class Duplicati
  class Backup
    def initialize(opts)
      @duplicati_path = opts[:duplicati_path]
      @backup_paths = opts[:backup_paths] or raise ":backup_paths option is missing for backup!"
      @backup_store_path = opts[:backup_store_path] or raise ":backup_store_path option is missing for backup!"
      @backup_encryption_key = opts[:backup_encryption_key]
      @inclusion_filters = opts[:inclusion_filters] || []
      @exclusion_filters = opts[:exclusion_filters] || []
      @log_path = opts[:log_path]
    end

    def command
      %Q["#{@duplicati_path}" backup "#{backup_paths}" "#{@backup_store_path}"
             #{encryption_option}
             #{inclusion_filters}
             #{exclusion_filters}
             --auto-cleanup                        
             --full-if-older-than=1M
             --usn-policy=on
             --snapshot-policy=on
             --full-if-sourcefolder-changed
             2>&1 1>> "#{@log_path}" &&

             "#{@duplicati_path}" delete-all-but-n 5 "#{@backup_store_path}"
             --force
             2>&1 1>> "#{@log_path}"]
    end

    private

    def encryption_option
      @backup_encryption_key ? 
        %Q[--passphrase="#{@backup_encryption_key}"] :
        %Q[--no-encryption]
    end

    def backup_paths
      @backup_paths.map do |path|
        path = path.strip.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
        Dir.glob(path.gsub(/\/$/, ""))
      end.flatten.join(File::PATH_SEPARATOR)
    end

    def inclusion_filters
      filters "include", @inclusion_filters
    end

    def exclusion_filters
      filters "exclude", @exclusion_filters
    end

    def filters(type, filters)
      filters.reduce([]) do |memo, filter|
        memo << %Q[--#{type}-regexp="#{filter.source}"]
      end.join(" ")
    end
  end
end
