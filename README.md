# Gmail Filters

*The things we do because Gmail rules do not allow to delete a label*

Experimental, not much to see.

## Usage

Define filters in Ruby files, e.g.:

```ruby
# ~/.gmail_filters/trash.rb

filter do
  has 'in:spam'
  archive
  mark_read
end

filter do
  from 'newsletter@email.com', 'bob@recruiter.com'
  archive
  mark_read
  delete
end
```

To exclude conditions from previous filters:

```ruby
# ~/.gmail_filters/github.rb

filter do
  list  'foo.my-org.github.com'
  # ...
end

filter do
  list  'bar.my-org.github.com'
  # ...
end

# exports "list:*.my-org@github.com AND -(list:foo.my-org@github.com OR list:bar.my-org.github.com)
otherwise do
  list  '*.my-org.github.com'
  # ...
end
```

Optionally configure author and email:

```yaml
# ~/.gmail_filters/config.yml

author: Sven Fuchs
email: me@svenfuchs.com
```

Export to XML:

```
$ bin/gmail-filters export
```

## Credits

**Heavily** inspired by [@antifuchs](https://github.com/antifuchs)' very nice [gmail-britta](https://github.com/antifuchs/gmail-britta).


