require "spec_helper"

describe Duplicati do
  before do
    allow_message_expectations_on_nil
  end

  context "#initialize" do

    it "has specified default log path" do
      Duplicati.new.opts[:log_path].should == "duplicati.log"
    end

    it "allows to specify log path" do
      Duplicati.new(:log_path => "/foo/bar").opts[:log_path].should == "/foo/bar"
    end

    it "has default duplicati path" do
      duplicati = Duplicati.new
      File.basename(duplicati.opts[:duplicati_path]).should == duplicati.send(:duplicati_executable_name)
    end

    it "allows to specify duplicati path via options" do
      Duplicati.new(:duplicati_path => "/zzz/baz/duplicati-commandline").opts[:duplicati_path].should == "/zzz/baz/duplicati-commandline"
    end

    it "allows to specify duplicati path via environment variable" do
      begin
        ENV["DUPLICATI_PATH"] = "/env/path/duplicati-commandline"
        Duplicati.new.opts[:duplicati_path].should == "/env/path/duplicati-commandline"
      ensure
        ENV.delete "DUPLICATI_PATH"
      end
    end

    it "has default notifications" do
      notifications = Duplicati.new.opts[:notifications]
      notifications.size.should == 1
      notifications.first.should be_kind_of(Duplicati::Notification::Growl)
    end

    it "allows to specify notifications" do
      Duplicati.new(:notifications => [Object]).opts[:notifications].should == [Object]
    end

    it "allows to specify other options" do
      Duplicati.new(:foo => true).opts[:foo].should be_true
    end

    it "has no inclusion filters by default" do
      Duplicati.new.opts[:inclusion_filters].should == []
    end

    it "allows to specify a single inclusion filter" do
      Duplicati.new(:inclusion_filter => /aa/).opts[:inclusion_filters].should == [/aa/]
    end

    it "allows to specify multiple inclusion filters" do
      Duplicati.new(:inclusion_filters => [/aa/, /bb/]).opts[:inclusion_filters].should == [/aa/, /bb/]
    end

    it "will set up an 'exclude all others files' exclusion filter automatically when inclusion filter is used" do
      Duplicati.new(:inclusion_filter => /aa/).opts[:exclusion_filters].should == [%r{.*[^\\/]}]
    end

    it "has no exclusion filters by default" do
      Duplicati.new.opts[:exclusion_filters].should == []
    end

    it "allows to specify a single exclusion filter" do
      Duplicati.new(:exclusion_filter => /aa/).opts[:exclusion_filters].should == [/aa/]
    end

    it "allows to specify multiple exclusion filters" do
      Duplicati.new(:exclusion_filters => [/aa/, /bb/]).opts[:exclusion_filters].should == [/aa/, /bb/]
    end

  end

  context "#backup" do
    it "executes the backup command and returns self" do
      Duplicati::Backup.any_instance.should_receive(:command).and_return("backup command")
      duplicati = Duplicati.new(:backup_paths => [], :backup_store_path => "")
      duplicati.should_receive(:execute).with("backup command")

      duplicati.backup.should == duplicati
    end

    it "proxies options to backup command" do
      duplicati_path = "/foo/bar/duplicati-commandline"
      options = {
        :duplicati_path => duplicati_path,
        :backup_paths => ["foo", "bar"],
        :backup_encryption_key => "secret",
        :backup_store_path => "baz",
        :inclusion_filters => [],
        :exclusion_filters => [],
        :log_path => "tmp"
      }
      expected_options = options.dup
      Duplicati::Backup.should_receive(:new).with(expected_options).and_return(double('backup').as_null_object)
      Duplicati.any_instance.stub(:execute)

      Duplicati.new(options).backup
    end
  end

  context ".backup" do
    it "is a convenience method for .new#backup#clean#notify" do
      Duplicati::Backup.any_instance.should_receive(:command).and_return("backup command")
      Duplicati.any_instance.should_receive(:execute).with("backup command")
      Duplicati::Clean.any_instance.should_receive(:command).and_return("clean command")
      Duplicati.any_instance.should_receive(:execute).with("clean command")
      Duplicati.any_instance.should_receive(:notify)

      Duplicati.backup(:backup_paths => [], :backup_store_path => "", :notifications => [])
    end
  end

  context "#execute" do

    before do
      Duplicati.any_instance.stub(:notify)
    end

    it "executes the command" do
      cmd = "multiline
        command     with  spaces"
      $?.should_receive(:exitstatus).and_return 0
      Object.any_instance.should_receive(:system).with("multiline command with spaces")

      Duplicati.new.send(:execute, cmd)
    end

    context "#execution_success?" do
      it "is false when command fails with negative exit status" do
        Object.any_instance.should_receive(:system).and_return false
        $?.should_receive(:exitstatus).and_return -1

        duplicati = Duplicati.new
        duplicati.send(:execute, "")
        duplicati.should_not be_execution_success
      end

      it "is false when command fails with exit status above 2" do
        Object.any_instance.should_receive(:system).and_return false
        $?.should_receive(:exitstatus).and_return 3

        duplicati = Duplicati.new
        duplicati.send(:execute, "")
        duplicati.should_not be_execution_success
      end

      it "is false when one of the commands fail with invalid exit status" do
        duplicati = Duplicati.new

        Object.any_instance.should_receive(:system).twice.and_return true
        $?.should_receive(:exitstatus).and_return 0
        duplicati.send(:execute, "")
        duplicati.should be_execution_success

        $?.should_receive(:exitstatus).and_return 3
        duplicati.send(:execute, "")
        duplicati.should_not be_execution_success
      end

      it "is true when command succeeds with exit status 0" do
        Object.any_instance.should_receive(:system).and_return true
        $?.should_receive(:exitstatus).and_return 0

        duplicati = Duplicati.new
        duplicati.send(:execute, "")
        duplicati.should be_execution_success
      end

      it "is true when command succeeds with exit status 1" do
        Object.any_instance.should_receive(:system).and_return true
        $?.should_receive(:exitstatus).and_return 1

        duplicati = Duplicati.new
        duplicati.send(:execute, "")
        duplicati.should be_execution_success
      end

      it "is true when command succeeds with exit status 2" do
        Object.any_instance.should_receive(:system).and_return true
        $?.should_receive(:exitstatus).and_return 2

        duplicati = Duplicati.new
        duplicati.send(:execute, "")
        duplicati.should be_execution_success
      end

      it "is true when all of the commands succeed with success exit status" do
        duplicati = Duplicati.new

        Object.any_instance.should_receive(:system).twice.and_return true
        $?.should_receive(:exitstatus).twice.and_return 0
        duplicati.send(:execute, "")
        duplicati.should be_execution_success

        duplicati.send(:execute, "")
        duplicati.should be_execution_success
      end
    end

    context "#notify" do
      before do
        Duplicati.any_instance.unstub(:notify)
      end

      it "returns self" do
        duplicati = Duplicati.new
        duplicati.notify.should == duplicati
      end

      it "notifies with all possible notifications with false execution success" do
        notification1 = double('notification1').as_null_object
        notification2 = double('notification2').as_null_object
        notification1.should_receive(:notify).with(false)
        notification2.should_receive(:notify).with(false)

        duplicati = Duplicati.new(:notifications => [notification1, notification2])
        duplicati.should_receive(:execution_success?).twice.and_return(false)
        duplicati.notify
      end

      it "notifies with all possible notifications with true execution success" do
        notification1 = double('notification1').as_null_object
        notification2 = double('notification2').as_null_object
        notification1.should_receive(:notify).with(true)
        notification2.should_receive(:notify).with(true)

        duplicati = Duplicati.new(:notifications => [notification1, notification2])
        duplicati.should_receive(:execution_success?).twice.and_return(true)
        duplicati.notify
      end
    end

  end
end
