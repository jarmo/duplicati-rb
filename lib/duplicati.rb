require File.expand_path("duplicati/version", File.dirname(__FILE__))
require File.expand_path("duplicati/command", File.dirname(__FILE__))
require File.expand_path("duplicati/backup", File.dirname(__FILE__))
require File.expand_path("duplicati/clean", File.dirname(__FILE__))
require File.expand_path("duplicati/notification/base", File.dirname(__FILE__))
require File.expand_path("duplicati/notification/growl", File.dirname(__FILE__))
require File.expand_path("duplicati/notification/mail", File.dirname(__FILE__))

class Duplicati

  class << self
    def backup(opts={})
      new(opts).backup.clean.notify
    end
  end

  attr_reader :opts

  def initialize(opts={})
    opts[:log_path] ||= "duplicati.log"
    opts[:duplicati_path] = duplicati_path(opts[:duplicati_path])
    opts[:notifications] ||= [Notification::Growl.new]
    opts[:inclusion_filters] ||= [opts[:inclusion_filter]].compact
    opts[:exclusion_filters] ||= [opts[:exclusion_filter]].compact

    if !opts[:inclusion_filters].empty? && opts[:exclusion_filters].empty?
      opts[:exclusion_filters] = [%r{.*[^\\/]}] 
    end

    @opts = opts
    @execution_success = true
  end

  def backup
    execute Backup.new(
      options :duplicati_path, :backup_paths, :backup_store_path,
      :backup_encryption_key, :inclusion_filters, :exclusion_filters, :log_path
    ).command

    self
  end

  def clean
    execute Clean.new(
      options :duplicati_path, :backup_store_path, :backup_encryption_key, :log_path
    ).command

    self
  end

  def notify
    @opts[:notifications].each do |notification|
      notification.notify execution_success?
    end

    self
  end

  # https://code.google.com/p/duplicati/issues/detail?id=678
  # 0 - Success
  # 1 - Success (but no changed files)
  # 2 - Completed by retried some files, or some files were locked (warnings)
  # 50 - Some files were uploaded, then connection died
  # 100 - No connection to server -> Fatal error
  # 200 - Invalid command/arguments
  def execution_success?
    @execution_success &&= @exit_status && @exit_status.between?(0, 2)
  end

  private

  def duplicati_path(path_from_options)
    path_from_options || ENV["DUPLICATI_PATH"] || (ENV["OS"] == "Windows_NT" ? "/Program Files/Duplicati/Duplicati.CommandLine" : "duplicati-commandline")
  end

  def execute(command)
    formatted_command = format command
    puts formatted_command if $DEBUG
    system(formatted_command)
    @exit_status = $?.exitstatus
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

end

