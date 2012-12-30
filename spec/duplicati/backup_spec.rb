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
        :log_path => "/zzz/output.log"
      ).command.should == %Q["/bin/duplicati-commandline" backup "#{basedir}#{File::PATH_SEPARATOR}#{File.join(basedir, "../").chop}" "file:///foo/backup"
             --passphrase="secret"
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
      command = Duplicati::Backup.new(:backup_paths => [], :backup_store_path => "").command
      command.should include("--no-encryption")
      command.should_not include("--passphrase")
    end

    it "works with globs for backup paths" do
      Duplicati::Backup.new(:backup_paths => [File.join(basedir, "../*_helper*")], :backup_store_path => "").
        command.split(" ")[2].should == "\"#{File.join(basedir, "../spec_helper.rb")}\""
    end

    it "ignores not-existing backup paths" do
      Duplicati::Backup.new(:backup_paths => ["/foo/bar", basedir, "/baz/bar"], :backup_store_path => "").
        command.split(" ")[2].should == "\"#{basedir}\""
    end

  end
end
