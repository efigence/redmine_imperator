# Redmine Imperator

> A Redmine API Plugin

[![Build Status](https://travis-ci.org/efigence/redmine_imperator.svg?branch=master)](https://travis-ci.org/efigence/redmine_imperator) [![Coverage Status](https://coveralls.io/repos/github/efigence/redmine_imperator/badge.png?branch=master)](https://coveralls.io/github/efigence/redmine_imperator?branch=master) [![Code Climate](https://codeclimate.com/github/efigence/redmine_imperator/badges/gpa.svg)](https://codeclimate.com/github/efigence/redmine_imperator) [![License](http://img.shields.io/:license-gpl3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0.html)

## Requirements

Developed and tested on Redmine 3.0, Ruby version 2.1

## Installation

1. Go to your Redmine installation's plugins/directory.
2. `git clone https://github.com/efigence/redmine_imperator`
3. run `bundle install`
4. Go back to root directory.
5. `bundle exec rake redmine:plugins:migrate RAILS_ENV=production`
6. Restart Redmine.

## Plugin Development & Testing

When adding new gems, they may conflict with Redmine's gems, so always run bundle first from redmine repository to be able to generate next a compatible Gemfile.lock in the plugin dir.

```
cd ~/redmine/
bundle install
cd ~/redmine/plugins/redmine_imperator/
bundle install --path vendor/bundle
cp config/database.yml.example config/database.yml
cp config/settings.yml.example config/settings.yml

# run tests
cd ~/redmine/
bundle exec rake redmine:plugins:test NAME=redmine_imperator
```

## Tests can be run inside a plugin, but additional setup is required

```
# first, follow instructions from: https://github.com/dadooda/bundler-gemlocal
# if you use ~/.bash_profile separately from ~/.bashrc, also source the .sh file there
cd ~/redmine/plugins/redmine_imperator/

# copy config files
cp Gemlocal.example Gemlocal

# install local gems
b install --path vendor/bundle

# run tests inside the plugin
bx rake test

# generate documentation for the plugin
bx rake rdoc
```

## Usage examples

```
curl -v -H "Content-Type: application/json" -X GET \
  -H "X-Redmine-API-Key: d293e1fbcae7e08c6f135d736e2f7f1be2d5eb35" \
  -H "X-Imperator-API-Key: 2ce03d6ea21775217f0ef4b8e56ce51abf86977a34270147b78210dc24632eda20f2b26fea440953cdeb2cb0fd6b82cbe2254a48f2b5d916db48e9851d9200d0" \
  http://localhost:3000/imperator_api/v1/users/1.json
```

## Agile Project Management and Collaboration

This project was built using [Pivotal Tracker](https://www.pivotaltracker.com/projects/1580447/). Please adhere to [A GUIDE TO GITHUB’S SERVICE HOOK FOR TRACKER](http://www.pivotaltracker.com/community/tracker-blog/guide-githubs-service-hook-tracker).

## License

Redmine Imperator plugin.
Copyright (C) 2016 Efigence S.A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
