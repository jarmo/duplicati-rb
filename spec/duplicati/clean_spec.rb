require "spec_helper"

describe Duplicati::Clean do

  context "#initialize" do
    it "raises an Exception if backup store path is not provided" do
      expect {
        Duplicati::Clean.new(:backup_paths => [])
      }.to raise_error(RuntimeError, ":backup_store_path option is missing!")
    end
  end

  context "#command" do

    it "generates clean command for Duplicati using different options" do
      Duplicati::Clean.new(
        :duplicati_path => "/bin/duplicati-commandline",
        :backup_store_path => "file:///foo/backup",
        :log_path => "/zzz/output.log"
      ).command.should == %Q["/bin/duplicati-commandline" delete-all-but-n 1 "file:///foo/backup"
             --no-encryption
             --force
             1>>"/zzz/output.log"
             2>&1]
    end

    it "generates clean command for Duplicati using backup encryption" do
      Duplicati::Clean.new(
        :duplicati_path => "/bin/duplicati-commandline",
        :backup_store_path => "file:///foo/backup",
        :backup_encryption_key => "foobar",
        :log_path => "/zzz/output.log"
      ).command.should == %Q["/bin/duplicati-commandline" delete-all-but-n 1 "file:///foo/backup"
             --passphrase="foobar"
             --force
             1>>"/zzz/output.log"
             2>&1]
    end

  end
end
