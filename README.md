# federal_register

Ruby API Client for FederalRegister.gov that handles searching articles and getting basic information about agencies.

For more information about the FederalRegister.gov API, see http://www.federalregister.gov/learn/developers

## Usage

```ruby
FederalRegister::Article.find('2011-17721').title
result_set = FederalRegister::Article.search(:conditions => {:term => "Accessibility"})
# or result_set = FederalRegister.find_all('2011-17721','2011-17722')
result_set.count
result_set.results.each do |article|
  puts "#{article.title} by #{article.agencies.map(&:name)}"
end

FederalRegister::Agency.all.each do |agency|
  puts agency.name
end
```

## Contributing to federal_register
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
