# bundler-alive

![bundler-alive](https://github.com/kyoshidajp/bundler-alive/actions/workflows/ci.yml/badge.svg)

`bunder-alive` checks if gems in a RubyGem's `Gemfile.lock` are active.

Currently only github.com is supported as a source code repository. If the source code repository is archived, then reports as not alive.

## Installation

```
$ gem install bunlder-alive
```

## Usage

```
$ bundle-alive
Name: journey
URL: http://github.com/rails/journey
Status: false

Not alive gems are found!
```

Default `Gemfile.lock` location is in your current directory. You can specify it.

```
$ bundle-alive -G /path/to/Gemfile.lock
```

In most cases, the following error is output.

```
Too many requested! Retry later.
```

In this case, setting [GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) as `BUNDLER_ALIVE_GITHUB_TOKEN` environment variable may alleviate the error.

If you run again, it will resume.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyoshidajp/bunlder-alive.
