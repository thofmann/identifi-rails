Identifi-rails
==============

Ruby on Rails interface for [Identifi](https://github.com/identifi/identifi)

Running
-------
Using [RVM](http://rvm.io/) for Ruby is recommended.

    git clone https://github.com/identifi/identifi-rails
    gem install bundler
    cd identifi-rails
    bundle install
    cp config/config.yml.example config/config.yml
    # Edit config.yml
    rake assets:precompile
    rails server
