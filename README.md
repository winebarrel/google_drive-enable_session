# GoogleDrive::EnableSession

Persist credential for [google-drive-ruby](https://github.com/gimite/google-drive-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google_drive-enable_session'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_drive-enable_session

## Usage

```ruby
require 'google_drive/enable_session'

#GoogleDrive::EnableSession.credential_store_file = '~/google_drive-oauth2.json'

include GoogleDrive::EnableSession

enable_session do |session|
  # Gets list of remote files.
  for file in session.files
    p file.title
  end
end
```
