require File.expand_path("duplicati/version", File.dirname(__FILE__))
require File.expand_path("duplicati/backup", File.dirname(__FILE__))
require File.expand_path("duplicati/notification/growl", File.dirname(__FILE__))

class Duplicati

  class << self
    def backup(opts={})
      new(opts).backup
    end
  end

  def initialize(opts={})
    opts[:log_path] ||= "duplicati.log"
    opts[:duplicati_path] = duplicati_path(opts[:duplicati_path])
    opts[:notifications] ||= [Notification::Growl]
    @opts = opts
  end

  def backup
    execute Backup.new(
      options :duplicati_path, :backup_paths, :backup_store_path, :backup_encryption_key, :log_path
    ).command
  end

  def duplicati_path(path_from_options)
    path = path_from_options || ENV["DUPLICATI_PATH"] || "/Program Files/Duplicati"
    File.join(File.exists?(path) ? path : "", "Duplicati.CommandLine")
  end

  private

  def execute(command)
    old_log_file_size = File.read(@opts[:log_path]).strip.size rescue 0
    @execution_success = system(format command) && File.read(@opts[:log_path]).strip.size > old_log_file_size
    notify
    exit @execution_success ? 0 : 1
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

