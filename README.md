# Boomi Atomsphere API client for Ruby

Unofficial Ruby client for the Dell Boomi Atomsphere API. Implements the JSON flavour of Boomi's "RESTish" API.

## Status

Implements authentication (including OTP), querying, and some actions. See *Usage* below.

## Usage

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

```ruby
# create a new query
query = Atomsphere::Query.new

# specify the object type to query
query.object_type = 'Process'

# filter for query names starting with 'Netsuite'
query.filter = Atomsphere::Query::GroupingExpression.new(
  operator: :and,
  nested_expression: [
    Atomsphere::Query::SimpleExpression.new(
      operator: :equals,
      property: :name,
      argument: ['Netsuite%']
    )
  ]
)

# run the query (fetches first page)
query.run

# see results from all pages that have been fetched
query.results

# fetch the next page (returns `false` if `last_page?` is `true`)
query.next_page

# fetch and show all pages of results (warning: loops over `next_page`)
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
