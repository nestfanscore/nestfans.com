## Ruby China

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build Status](https://travis-ci.org/ruby-china/ruby-china.svg?branch=master)](https://travis-ci.org/ruby-china/ruby-china) [![Code Climate](https://codeclimate.com/github/ruby-china/ruby-china/badges/gpa.svg)](https://codeclimate.com/github/ruby-china/ruby-china) [![codecov.io](https://codecov.io/github/ruby-china/ruby-china/coverage.svg?branch=master)](https://codecov.io/github/ruby-china/ruby-china?branch=master)

## Requirements

* Ruby 2.3.0 +
* PostgreSQL 9.4 +
* Redis 2.8 +
* Memcached 1.4 +
* ImageMagick 6.5 +
* Elasticsearch 2.0 +

## Install in development

### Vagrant

Install VirtualBox + Vagrant:

- https://www.virtualbox.org/
- https://www.vagrantup.com/

Then:

```bash
$ vagrant up
$ vagrant ssh
$ cd /vagrant
/vagrant $ ./bin/setup
/vagrant $ rails s -b 0.0.0.0
```

Open http://localhost:3000 in host.

### Mac OS X, use Homebrew

```bash
$ brew install memcached
$ brew install redis
$ brew install postgresql
$ brew install imagemagick
$ brew install gs
$ brew install elasticsearch
```

### Ubuntu

```bash
$ sudo apt-get install memcached postgresql-9.4 redis-server imagemagick ghostscript
```

Install Elasticsearch

```bash
curl -sSL https://git.io/vVHhm | bash
```

```bash
$ git clone https://github.com/ruby-china/ruby-china.git
$ cd ruby-china
$ ./bin/setup
Checking Package Dependencies...
--------------------------------------------------------------------------------
Redis 2.0+                                                                 [Yes]
Memcached 1.4+                                                             [Yes]
ImageMagick 6.5+                                                           [Yes]
--------------------------------------------------------------------------------

Installing dependencies
--------------------------------------------------------------------------------
The Gemfile's dependencies are satisfied
--------------------------------------------------------------------------------

Configure
--------------------------------------------------------------------------------
Your Redis host (default: 127.0.0.1:6379):
Your Elasticsearch host (default: 127.0.0.1:9200):
--------------------------------------------------------------------------------

Seed default data...                                                      [Done]

== Removing old logs and tempfiles ==

Ruby China Successfully Installed.

$ rails s
```

## Testing

```bash
bundle exec rake
```

## About Emoji Asset files

You may see emoji files 404 not found, after you publish you app. Because the emoji not include into Assets Pipline, what reason you can read Issue #522.

You need upload emoji images into `/assets/emojis` production environment path / CDN path, you can find image here: [md_emoji](https://github.com/elm-city-craftworks/md_emoji/tree/master/vendor/assets/images/emojis)

## Contributors

* [Contributors](https://github.com/ruby-china/ruby-china/contributors)

## Thanks

* [Twitter Bootstrap](https://twitter.github.com/bootstrap)
* [Font Awesome](http://fortawesome.github.io/Font-Awesome/icons/)
* [Google Roboto Font](https://github.com/google/roboto)

Forked from [Homeland Project](https://github.com/huacnlee/homeland)
Theme from [Mediom](https://github.com/huacnlee/mediom)

## Sites

* [Ruby China](https://ruby-china.org)
* [36kr](http://36kr.com/)
* [TesterHome](https://testerhome.com)
* [Coding Style](https://codingstyle.cn)
* [DiyCode](http://www.diycode.cc/)
* [Japan Trip](http://www.japantrip.cn/)

## License

Copyright (c) 2011-2016 Ruby China

Released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)
