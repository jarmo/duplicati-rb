# Duplicati
[![Build Status](https://secure.travis-ci.org/jarmo/duplicati-rb.png)](http://travis-ci.org/jarmo/duplicati-rb)
[![Coverage](https://coveralls.io/repos/jarmo/duplicati-rb/badge.png?branch=master)](https://coveralls.io/r/jarmo/duplicati-rb)

This gem is a [Duplicati](http://duplicati.com) backup utility wrapper written in Ruby with easier API and sensible configuration defaults compared to Duplicati's own utilities.

## Installation

1. Install [Duplicati](http://duplicati.com) itself.
2. Install Duplicati gem.

Add this line to your application's Gemfile:

    gem 'duplicati'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install duplicati

## Usage

````ruby
require "duplicati"

Duplicati.backup(
  :backup_paths => ["/foo/bar", "/foo/baz"],
  :backup_store_path => "file:///backup",
  :backup_encryption_key => "very-secret-key"
)
````

Refer to [Duplicati documentation](http://duplicati.com/howtos) for different backup store locations.

## Filters

Duplicati allows to specify inclusion and exclusion filters when it comes to backups, restoring and so on.

It has [quite complex filtering API](https://code.google.com/p/duplicati/wiki/FilterUsage), which this gem tries to simplify.

To include only .txt files, you need to write this:

````ruby
Duplicati.backup(:inclusion_filter => /.*\.txt$/)
````

Globs are also supported:
````ruby
Duplicati.backup(:inclusion_filter => "*.mp3")
````

It is also possible to have multiple filters:
````ruby
Duplicati.backup(:inclusion_filters => [/.*\.txt$/, "*.mp3"])
````

Exclusion filters work similarly:
````ruby
Duplicati.backup(:exclusion_filter => "*.exe")
````

## Notifications

Duplicati gem supports currently two different notifications.

### Growl

Growl notifications are enabled by default if not specified otherwise.

For these to work you need to install [Growl](http://growl.info/) or [Growl for Windows](http://www.growlforwindows.com) and
a [ruby_gntp](https://github.com/snaka/ruby_gntp) gem.

You can enable Growl notifications manually by specifying ````:notifications```` option like this:

````ruby
Duplicati.backup(
  :notifications => [Duplicati::Notification::Growl.new],
  # other options
)
````

### E-mail

To use e-mail notifications, you need to install [mail](https://github.com/mikel/mail) gem.

After that you need to specify ````:notifications```` option like this:

````ruby
Duplicati.backup(
  :notifications => [
    Duplicati::Notification::Mail.new(
      :to => "recipient@example.com",
      :smtp_config => { :domain => "example.com", :address => "mail.example.com" }
    )
  ],
  # other options
)
````


### Multiple notifications

You can use multiple notifications together by specifying them in the ````:notifications```` option array:

````ruby
Duplicati.backup(:notifications => [NotificationClass1.new, NotificationClass2.new, ...])
````

### Disabling notifications

To disable all notifications, you need to pass an empty array to ````:notifications```` option:

````ruby
Duplicati.backup(:notifications => [])
````

### Others

It is really easy to add new notification types by just implementing one class with single method called ````#notify````.

This method takes a single boolean argument called ````success```` which will be true if the Duplicati command succeeded
and false otherwise. For example:

````ruby
class CustomNotification
  def notify(success)
    if success
      # notify with success message
    else
      # notify with failure message
    end
  end
end
````

## Execution status

Duplicati has a ````#execution_success?```` method for determining the success
status of backup command:

````ruby
Duplicati.backup(options).execution_success? # => "true" when execution was a success.
````

## Fine Grained Commands Execution

It is possible to execute commands separately when needed:

````ruby
Duplicati.backup(options).execution_success?
# is same as
Duplicati.new(options).backup.clean.notify.execution_success?
````

## Limitations

* Currently only backup is supported. Use Duplicati's command line or GUI utility directly for restoring.
* You need to start Ruby with administrative privileges under Windows to backup files in use.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
