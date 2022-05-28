# bundler-alive

[![Gem Version](https://badge.fury.io/rb/bundler-alive.svg)](https://badge.fury.io/rb/bundler-alive)
![bundler-alive](https://github.com/kyoshidajp/bundler-alive/actions/workflows/ci.yml/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/a79d53257bc5e93842f6/maintainability)](https://codeclimate.com/github/kyoshidajp/bundler-alive/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a79d53257bc5e93842f6/test_coverage)](https://codeclimate.com/github/kyoshidajp/bundler-alive/test_coverage)

`bundler-alive` checks if gems in a RubyGem's `Gemfile.lock` are active.

Currently, GitHub.com and GitLab.com are supported as a source code repository. If the source code repository is archived, then reports as not alive.

## Installation

```
$ gem install bundler-alive
```

## Usage

```
$ bundle-alive
6 gems are in Gemfile.lock
..W....
Get all source code repository URLs of gems are done!
.....

Errors:
    [bundle-alive] Not found in RubyGems.org.

Archived gems:
    Name: journey
    URL: http://github.com/rails/journey

Total: 6 (Archived: 1, Alive: 4, Unknown: 1)
Not alive gems are found!
```

Default `Gemfile.lock` location is in your current directory. You can specify it.

```
$ bundle-alive -G /path/to/Gemfile.lock
```

## Access Token

You MUST set environment variables to access source code repository services.

| Repository service | ENV variable |
| ------- |---- |
| GitHub | [`BUNDLER_ALIVE_GITHUB_TOKEN`](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) |
| GitLab | [`BUNDLER_ALIVE_GITLAB_TOKEN`](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) |

## Ignore gems

You can ignore certain gems.

```
$ bundle-alive -i journey rubocop-junit-formatter
```

## Specifying repository URL

In some cases, some gems cannot find the URL of their source code repositories. For this case, you can specify a mapping between the gem and its URL.

Put `.bundler-alive.yml` in your current directory. The following code is the sample.

```yaml
---
gems:
  coffee-script-source:
    url: https://github.com/jashkenas/coffeescript/
```

You can also specify the file path.

```
$ bundle-alive -c /path/to/.bundler-alive.yml
```

[.bundler-alive.default.yml](https://github.com/kyoshidajp/bundler-alive/blob/main/.bundler-alive.default.yml) may also be helpful. Considering that having these mappings obtained automatically in the future.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyoshidajp/bunlder-alive.

## Thanks

This gem was inspired by the following products.

- [bundler-audit](https://github.com/rubysec/bundler-audit)
- [良いコード／悪いコードで学ぶ設計入門 ―保守しやすい 成長し続けるコードの書き方](https://gihyo.jp/book/2022/978-4-297-12783-1)
