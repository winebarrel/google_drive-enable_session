# GoogleDrive::EnableSession

# Notice
**Please use [google_drive-persistent_session](https://github.com/winebarrel/google_drive-persistent_session)!!**
---

Persist credential for [google-drive-ruby](https://github.com/gimite/google-drive-ruby).

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
