class Duplicati
  module Notification
    class Growl < Base
      def notify(success)
        return unless load_gem "ruby_gntp"

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
    end
  end
end
