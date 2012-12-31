require File.expand_path(File.dirname(__FILE__))  + "/base"

class Duplicati
  module Notification
    class Mail < Base
      def initialize(opts={})
        @smtp_config = {:port => 25, :openssl_verify_mode => "none"}.merge(opts[:smtp_config] || {})
        @to = opts[:to]
      end

      def notify(success)
        return unless load_gem "mail"

        smtp_config = @smtp_config
        to_address = @to

        ::Mail.deliver do
          delivery_method :smtp, smtp_config

          to to_address
          from "backup@duplicati.com"
          subject "#{`hostname`.strip} - Backup #{success ? "Succeeded" : "Failed"}!"
          body "#{Time.now} - backup #{success ? "succeeded" : "failed"}!"
        end
      rescue => e
        Kernel.warn "Failed to notify via Mail: #{e.message}"      
      end
    end
  end
end

