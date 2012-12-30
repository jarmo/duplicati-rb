require "spec_helper"

describe Duplicati::Backup do

  context "#initialize" do
  
    it "raises an Exception if backup paths are not provided" do
      expect {
        Duplicati::Backup.new(:backup_store_path => "")
      }.to raise_error(RuntimeError, ":backup_paths option is missing for backup!")
    end

    it "raises an Exception if backup store path is not provided" do
      expect {
        Duplicati::Backup.new(:backup_paths => [])
      }.to raise_error(RuntimeError, ":backup_store_path option is missing for backup!")
    end
  end

  context "#command" do

    let(:basedir) { File.dirname(__FILE__) }

    it "generates backup command for Duplicati using different options" do
      Duplicati::Backup.new(
        :duplicati_path => "/bin/duplicati-commandline",
        :backup_paths => [basedir, File.join(basedir, "../")],
        :backup_store_path => "file:///foo/backup",
        :backup_encryption_key => "secret",
        :inclusion_filters => [/include-me/],
        :exclusion_filters => [/exclude-me/],
        :log_path => "/zzz/output.log"
      ).command.should == %Q["/bin/duplicati-commandline" backup "#{basedir}#{File::PATH_SEPARATOR}#{File.join(basedir, "../").chop}" "file:///foo/backup"
             --passphrase="secret"
             --include-regexp="include-me"
             --exclude-regexp="exclude-me"
             --auto-cleanup                        
             --full-if-older-than=1M
             --usn-policy=on
             --snapshot-policy=on
             --full-if-sourcefolder-changed
             2>&1 1>> "/zzz/output.log" &&

             "/bin/duplicati-commandline" delete-all-but-n 5 "file:///foo/backup"
             --force
             2>&1 1>> "/zzz/output.log"]
    end

    it "generates backup command for Duplicati without using any encryption when encryption key is not provided" do
      command = Duplicati::Backup.new(:backup_paths => [], :backup_store_path => "", :inclusion_filters => [], :exclusion_filters => []).command
      command.should include("--no-encryption")
      command.should_not include("--passphrase")
    end

    it "works with globs for backup paths" do
      Duplicati::Backup.new(:backup_paths => [File.join(basedir, "../*_helper*")], :backup_store_path => "", :inclusion_filters => [], :exclusion_filters => []).
        command.split(" ")[2].should == "\"#{File.join(basedir, "../spec_helper.rb")}\""
    end

    it "ignores not-existing backup paths" do
      Duplicati::Backup.new(:backup_paths => ["/foo/bar", basedir, "/baz/bar"], :backup_store_path => "", :inclusion_filters => [], :exclusion_filters => []).
        command.split(" ")[2].should == "\"#{basedir}\""
    end

    it "works with inclusion filters" do
      command_parts = Duplicati::Backup.new(:backup_paths => [], :backup_store_path => "", :inclusion_filters => [/a\.exe/, /b\.exe/]).
        command.split(" ")

      command_parts[5].should == "--include-regexp=\"a\\.exe\""
      command_parts[6].should == "--include-regexp=\"b\\.exe\""
    end

    it "works with exclusion filters" do
      command_parts = Duplicati::Backup.new(:backup_paths => [], :backup_store_path => "", :exclusion_filters => [/a\.exe/, /b\.exe/]).
        command.split(" ")
      
      command_parts[5].should == "--exclude-regexp=\"a\\.exe\""
      command_parts[6].should == "--exclude-regexp=\"b\\.exe\""
    end

    it "works with inclusion and exclusion filters together" do
      command_parts = Duplicati::Backup.new(:backup_paths => [], :backup_store_path => "", :inclusion_filters => [/a/, /b/], :exclusion_filters => [/c/, /d/]).
        command.split(" ")

      command_parts[5].should == "--include-regexp=\"a\""
      command_parts[6].should == "--include-regexp=\"b\""
      command_parts[7].should == "--exclude-regexp=\"c\""
      command_parts[8].should == "--exclude-regexp=\"d\""
    end

    it "does not include filters into command when they're not specified" do
      command = Duplicati::Backup.new(:backup_paths => [], :backup_store_path => "").command
      command.should_not include("--include-regexp")
      command.should_not include("--exclude-regexp")
    end

  end
end
