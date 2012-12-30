class Duplicati
  module Notification
    class Growl
      def notify(success)
        return unless load_gem

        growl = GNTP.new("Backup")
        growl.register(:notifications => [{
          :name     => "backup-notify",
          :enabled  => true,
        }])

        growl.notify(
          :name  => "backup-notify",
          :title => "Backup",
          :text  => success ? "Backup successfully finished!" : "Backup failed!",
          :icon  => File.expand_path(success ? "success.png" : "failed.png", File.dirname(__FILE__))
        )
      rescue => e
        Kernel.warn "Failed to notify via Growl: #{e.message}"
      end

      private

      def load_gem
        require "ruby_gntp"
        true
      rescue LoadError
        Kernel.warn "ruby_gntp gem is not installed, which is needed for Growl notifications!"
        false
      end
    end
  end
end
