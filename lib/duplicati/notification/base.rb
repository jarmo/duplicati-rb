class Duplicati
  module Notification
    class Base
      def load_gem(name)
        require name
        true
      rescue LoadError
        Kernel.warn "#{name} gem is not installed, which is needed for #{self.class.name}!"
        false
      end
    end
  end
end
