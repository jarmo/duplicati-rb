require File.expand_path("duplicati/version", File.dirname(__FILE__))
require File.expand_path("duplicati/backup", File.dirname(__FILE__))
require File.expand_path("duplicati/notification/growl", File.dirname(__FILE__))

class Duplicati

  class << self
    def backup(opts={})
      new(opts).backup
    end
  end

  attr_reader :opts, :execution_success

  def initialize(opts={})
    opts[:log_path] ||= "duplicati.log"
    opts[:duplicati_path] = duplicati_path(opts[:duplicati_path])
    opts[:notifications] ||= [Notification::Growl]
    opts[:inclusion_filters] ||= [opts[:inclusion_filter]].compact
    opts[:exclusion_filters] ||= [opts[:exclusion_filter]].compact

    if !opts[:inclusion_filters].empty? && opts[:exclusion_filters].empty?
      opts[:exclusion_filters] = [%r{.*[^\\/]}] 
    end

    @opts = opts
  end

  def backup
    execute Backup.new(
      options :duplicati_path, :backup_paths, :backup_store_path,
        :backup_encryption_key, :inclusion_filters, :exclusion_filters, :log_path
    ).command
  end

  private

  def duplicati_path(path_from_options)
    path = path_from_options || ENV["DUPLICATI_PATH"] || "/Program Files/Duplicati"
    File.join(path, "Duplicati.CommandLine")
  end

  def execute(command)
    old_log_file_size = File.read(@opts[:log_path]).strip.size rescue 0
    formatted_command = format command
    puts formatted_command if $DEBUG
    @execution_success = system(formatted_command) && File.read(@opts[:log_path]).strip.size > old_log_file_size
    notify
  end

  def options(*options_to_extract)
    options_to_extract.reduce({}) do |memo, option|
      memo[option] = @opts[option]
      memo
    end
  end

  def format(command)
    command.gsub($/, "").squeeze(" ")
  end

  def notify
    @opts[:notifications].each do |notification|
      notification.notify @execution_success
    end
  end

end

