require "spec_helper"

describe Duplicati::Clean do

  context "#initialize" do
    it "raises an Exception if backup store path is not provided" do
      expect {
        Duplicati::Clean.new(:backup_paths => [])
      }.to raise_error(RuntimeError, ":backup_store_path option is missing for clean!")
    end
  end

  context "#command" do

    it "generates clean command for Duplicati using different options" do
      Duplicati::Clean.new(
        :duplicati_path => "/bin/duplicati-commandline",
        :backup_store_path => "file:///foo/backup",
        :log_path => "/zzz/output.log"
      ).command.should == %Q["/bin/duplicati-commandline" delete-all-but-n 5 "file:///foo/backup"
             --force
             2>&1 1>> "/zzz/output.log"]
    end

  end
end
