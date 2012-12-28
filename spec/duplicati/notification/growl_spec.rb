require "spec_helper"

describe Duplicati::Notification::Growl do

  before do
    Kernel.stub(:warn)
    Object.any_instance.stub(:require).with("ruby_gntp")
    GNTP = double('gntp').as_null_object unless defined?(GNTP) && GNTP.null_object?
  end

  let(:growl) { subject.class }

  it "notifies with success message" do
    GNTP.should_receive(:notify).with notification_args("Backup successfully finished!", "success.png")
    growl.notify(true)
  end

  it "notifies with failure message" do
    GNTP.should_receive(:notify).with notification_args("Backup failed!", "failed.png")
    growl.notify(false)    
  end

  it "does not blow up when ruby_gntp gem is not installed" do
    Object.any_instance.unstub(:require)
    GNTP.should_not_receive(:notify)

    expect {
      growl.notify(false)
    }.to_not raise_error
  end

  it "does not blow up when notifying fails" do
    GNTP.stub(:register) { raise "foo" }

    expect {
      growl.notify(false)
    }.to_not raise_error
  end

  def notification_args(text, icon)
    {
      :name  => "backup-notify",
      :title => "Backup",
      :text  => text,
      :icon  => File.expand_path(icon, File.join(File.dirname(__FILE__), "../../../lib/duplicati/notification"))
    }
  end

end
