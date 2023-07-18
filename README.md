# RBS::Heuristic::Prototype

Update prototype signature files by heuristic rules.

## Installation

Add a new entry to your Gemfile and run bundle install:

```
group :development do
  gem 'rbs_heuristic_prototype'
end
```

After the installation, please run rake task generator:

```
bundle exec rails g rbs_heuristic_prototype:install
```

Additionally, it would be better to add the following entry to your rbs_collection.yml:

```
gems:
  - name: rbs_heuristic_prototype
    ignore: true
```

## Usage

1. Run `rbs prototype rb` or `rbs prototype runtime` first
2. Run `rbs:prototype:heuristic:apply`

Then rbs_heuristic_prototype will update the prototype signature files generated
by `rbs prototype` according to the heuristic rules.

* Rule 1:
  * Convert a method ending with '?' to a method returning "boolish"
* Rule 2:
  * Convert a constant annotated with Array of Union of symbols (ex. `Array[:sym1 | :sym2 | ...]`) to a constant annotated with `Array[Symbol]`
  * This is useful to avoid `Ruby::IncompatibleAssignment` warning when right hand value uses `#freeze` method
    * ref: https://github.com/soutaro/steep/issues/363
* Rule 3:
  * Convert a callback method of ActiveModel subclass to a method returning "void" (ex. `before_save` callback)
* Rule 4:
  * Convert a scoped module/class definition (ex. `Foo::Bar::Baz`) to the nested definitions
  * This is useful to define intermediate modules automatically like what Rails and zeitwerk does.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also
run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, and then put
a git tag (ex. `git tag v1.0.0`) and push it to the GitHub. Then GitHub Actions
will release a new package to [rubygems.org](https://rubygems.org) automatically.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tk0miya/rbs_heuristic_prototype.
This project is intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [code of conduct](https://github.com/tk0miya/rbs_heuristic_prototype/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RbsHeuristicPrototype project's codebases, issue trackers is
expected to follow the [code of conduct](https://github.com/tk0miya/rbs_heuristic_prototype/blob/main/CODE_OF_CONDUCT.md).
