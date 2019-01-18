# Boomi Atomsphere API client for Ruby

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/atomsphere.svg)](https://badge.fury.io/rb/atomsphere)
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/atomsphere)

Unofficial Ruby client for the Dell Boomi Atomsphere API. Implements the JSON flavour of Boomi's "RESTish" API.

## Status

Implements authentication (including OTP), querying, and some actions. See *Usage* below.

## Usage

Install the `atomsphere` gem from rubygems or add it to your `Gemfile`:

```ruby
source 'https://rubygems.org'
gem 'atomsphere'
```

and require `atomsphere`:

```ruby
require 'atomsphere'
```

### Configuration

```ruby
Atomsphere.configure do |config|
  config.account_id = '' # Boomi account ID
  config.username   = '' # user name
  config.password   = '' # user password
  config.otp_secret = '' # base32 OTP secret for two-factor auth
end
```

Alternatively, environment variables may be used:
 * `BOOMI_ACCOUNT_ID`
 * `BOOMI_USERNAME`
 * `BOOMI_PASSWORD`
 * `BOOMI_OTP_SECRET`

### Querying

Generate a query for all _"Processes"_ that start with _"Production"_ and
contain _"NetSuite"_ or _"Salesforce"_:

```ruby
query = Atomsphere.query('Process') do
  group :and do
    name.like 'Production%'
    group :or do
      name.like '%NetSuite%'
      name.like '%Salesforce%'
    end
  end
end
```

Generate a query for all online Atoms:

```ruby
query = Atomsphere.query('Atom') do
  status.equals 'ONLINE'
  type.equals   'CLOUD'
end
```

Inspect the query filter:

```ruby
query.to_hash
query.to_json
```

Run the query:

```ruby
query.run
```

See results from all pages that have been fetched:

```ruby
query.results
```

Fetch the next page (returns `false` if `last_page?` is `true`):

```ruby
query.next_page
```

Iterate over `next_page` until `last_page?` is `true` and see all results:

```ruby
query.all_results
```

### Actions

```ruby
Atomsphere.get_assignable_roles
Atomsphere.execute_process atom_id: '12345-uuid-12345', process_id: '12345-uuid-12345'
Atomsphere.change_listener_status listener_id: '12345-uuid-12345', container_id: '12345-uuid-12345', action: :pause
```

## License

MIT License

Copyright (c) 2019 Warren Guy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
