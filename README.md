# bundler-alive

[![Gem Version](https://badge.fury.io/rb/bundler-alive.svg)](https://badge.fury.io/rb/bundler-alive)
![bundler-alive](https://github.com/kyoshidajp/bundler-alive/actions/workflows/ci.yml/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/a79d53257bc5e93842f6/maintainability)](https://codeclimate.com/github/kyoshidajp/bundler-alive/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a79d53257bc5e93842f6/test_coverage)](https://codeclimate.com/github/kyoshidajp/bundler-alive/test_coverage)

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

## Thanks

This gem was inspired by the following products.

- [bundler-audit](https://github.com/rubysec/bundler-audit)
- [良いコード／悪いコードで学ぶ設計入門 ―保守しやすい 成長し続けるコードの書き方](https://gihyo.jp/book/2022/978-4-297-12783-1)
