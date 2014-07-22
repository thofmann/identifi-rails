Identifi-rails
==============

Ruby on Rails interface for [Identifi](https://github.com/identifi/identifi)

Running
-------
Using [RVM](http://rvm.io/) for Ruby is recommended. A javascript runtime is required, install [NodeJS](http://nodejs.org/download/) unless you have one.

    git clone https://github.com/identifi/identifi-rails
    gem install bundler
    cd identifi-rails
    bundle install
    cp config/config.yml.example config/config.yml
    # Edit config.yml
    rake db:migrate
    rake assets:precompile
    rails server

[Phusion Passenger](https://www.phusionpassenger.com/) with nginx is an easy way to run a production server.
