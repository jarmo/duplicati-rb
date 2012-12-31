require "spec_helper"

describe Duplicati::Notification::Mail do

  before do
    Kernel.stub(:warn)
    Object.any_instance.stub(:require).with("mail")
    ::Mail = double('mail').as_null_object unless defined?(::Mail) && ::Mail.null_object?
  end

  let(:mail) { Duplicati::Notification::Mail.new(:to => "foo@example.com", :smtp_config => {:domain => "example.com", :port => 26})}
  let(:smtp_config) { {:port => 26, :openssl_verify_mode => "none", :domain => "example.com"} }

  it "notifies with message" do
    ::Mail.should_receive(:deliver)
    mail.notify(true)
  end

  it "does not blow up when mail gem is not installed" do
    Object.any_instance.stub(:require).with("mail") { raise LoadError }
    ::Mail.should_not_receive(:deliver)

    expect {
      mail.notify(false)
    }.to_not raise_error
  end

  it "does not blow up when notifying fails" do
    ::Mail.stub(:deliver) { raise "foo" }

    expect {
      mail.notify(false)
    }.to_not raise_error
  end

end
