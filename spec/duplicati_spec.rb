require "spec_helper"

describe Duplicati do
  context "#initialize" do

    it "has specified default log path" do
      Duplicati.new.opts[:log_path].should == "duplicati.log"
    end

    it "allows to specify log path" do
      Duplicati.new(:log_path => "/foo/bar").opts[:log_path].should == "/foo/bar"
    end

    it "has default duplicati path" do
      Duplicati.new.opts[:duplicati_path].should == "/Program Files/Duplicati/Duplicati.CommandLine"
    end

    it "allows to specify duplicati path via options" do
      Duplicati.new(:duplicati_path => "/zzz/baz").opts[:duplicati_path].should == "/zzz/baz/Duplicati.CommandLine"
    end

    it "allows to specify duplicati path via environment variable" do
      begin
        ENV["DUPLICATI_PATH"] = "/env/path"
        Duplicati.new.opts[:duplicati_path].should == "/env/path/Duplicati.CommandLine"
      ensure
        ENV.delete "DUPLICATI_PATH"
      end
    end

    it "has default notifications" do
      Duplicati.new.opts[:notifications].should == [Duplicati::Notification::Growl]
    end

    it "allows to specify notifications" do
      Duplicati.new(:notifications => [Object]).opts[:notifications].should == [Object]
    end

    it "allows to specify other options" do
      Duplicati.new(:foo => true).opts[:foo].should be_true
    end

  end

  context "#backup" do
    it "executes the backup command" do
      Duplicati::Backup.any_instance.should_receive(:command).and_return("backup command")
      duplicati = Duplicati.new
      duplicati.should_receive(:execute).with("backup command")

      duplicati.backup
    end

    it "proxies options to backup command" do
      duplicati_path = "/foo/bar"
      options = {
        :duplicati_path => duplicati_path,
        :backup_paths => ["foo", "bar"],
        :backup_encryption_key => "secret",
        :backup_store_path => "baz",
        :log_path => "tmp"
      }
      expected_formatted_options = options.dup
      expected_formatted_options[:duplicati_path] += "/Duplicati.CommandLine"
      Duplicati::Backup.should_receive(:new).with(expected_formatted_options).and_return(double('backup').as_null_object)
      Duplicati.any_instance.stub(:execute)

      Duplicati.new(options).backup
    end
  end

  context ".backup" do
    it "is a convenience method for .new#backup" do
      Duplicati::Backup.any_instance.should_receive(:command).and_return("backup command")
      Duplicati.any_instance.should_receive(:execute).with("backup command")

      Duplicati.backup
    end
  end
end