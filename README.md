# Duplicati
[![Build Status](https://secure.travis-ci.org/jarmo/duplicati-rb.png)](http://travis-ci.org/jarmo/duplicati-rb)
[![Coverage](https://coveralls.io/repos/jarmo/duplicati-rb/badge.png?branch=master)](https://coveralls.io/r/jarmo/duplicati-rb)

This gem is a [Duplicati](http://duplicati.com) backup utility wrapper written in Ruby with easier API and sensible configuration defaults compared to Duplicati's own utilities.

## Installation

Add this line to your application's Gemfile:

    gem 'duplicati'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install duplicati

## Usage

````
require "duplicati"

Duplicati.backup(
  :backup_paths => ["/foo/bar", "/foo/baz"],
  :backup_store_path => "file:///backup",
  :backup_encryption_key => "very-secret-key"
)
````

Refer to [Duplicati documentation](http://duplicati.com/howtos) for different backup store locations.

## Limitations

* Currently only backup is supported. Use command line or GUI utility directly for restoring.
* You need to start Ruby with administrative privileges under Windows to backup files in use.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
