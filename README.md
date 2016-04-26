# Redmine Imperator

> A Redmine API Plugin

[![Build Status](https://travis-ci.org/efigence/redmine_imperator.svg?branch=master)](https://travis-ci.org/efigence/redmine_imperator) [![Coverage Status](https://coveralls.io/repos/github/efigence/redmine_imperator/badge.png?branch=master)](https://coveralls.io/github/efigence/redmine_imperator?branch=master) [![Code Climate](https://codeclimate.com/github/efigence/redmine_imperator/badges/gpa.svg)](https://codeclimate.com/github/efigence/redmine_imperator) [![License](http://img.shields.io/:license-gpl3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0.html)

## Requirements

Developed and tested on Redmine 3.0.x

## Installation

1. Go to your Redmine installation's plugins/directory.
2. `git clone https://github.com/efigence/redmine_imperator`
3. run `bundle install`
4. Go back to root directory.
5. `bundle exec rake redmine:plugins:migrate RAILS_ENV=production`
6. Restart Redmine.

## Agile Project Management and Collaboration

This project was built using [Pivotal Tracker](https://www.pivotaltracker.com/projects/1580447/). Please adhere to [A GUIDE TO GITHUB’S SERVICE HOOK FOR TRACKER](http://www.pivotaltracker.com/community/tracker-blog/guide-githubs-service-hook-tracker).

## License

Redmine Hamster plugin.
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
