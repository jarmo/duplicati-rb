require "spec_helper"

describe Duplicati::Backup do
  it "#command" do
    Duplicati::Backup.new(
      :duplicati_path => "/bin/duplicati-commandline",
      :backup_paths => ["/foo/bar", "/baz/bar"],
      :backup_store_path => "file:///foo/backup",
      :backup_encryption_key => "secret",
      :log_path => "/zzz/output.log"
    ).command.should == %Q["/bin/duplicati-commandline" backup "/foo/bar#{File::PATH_SEPARATOR}/baz/bar" "file:///foo/backup"
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
end
