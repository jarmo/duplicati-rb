class Duplicati
  class Backup < Command
    def initialize(opts)
      super
      @backup_paths = opts[:backup_paths] or raise ":backup_paths option is missing for backup!"
      @inclusion_filters = opts[:inclusion_filters] || []
      @exclusion_filters = opts[:exclusion_filters] || []
    end

    def command
      %Q["#{@duplicati_path}" backup "#{backup_paths}" "#{@backup_store_path}"
             #{encryption_option}
             #{inclusion_filters}
             #{exclusion_filters}
             --volsize=100mb
             --auto-cleanup                        
             --full-if-older-than=1M
             --usn-policy=auto
             --snapshot-policy=auto
             --full-if-sourcefolder-changed
             1>>"#{@log_path}"
             2>&1]
    end

    private

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
        flag = "--#{type}"
        if filter.is_a?(Regexp)
          flag += %Q[-regexp="#{filter.source}"]
        else
          flag += %Q[="#{filter}"]
        end
        memo << flag
      end.join(" ")
    end
  end
end
