Juggernaut
================

[![Build Status](https://travis-ci.org/zooniverse/The-Juggernaut.png)](https://travis-ci.org/zooniverse/The-Juggernaut)

# Getting Started

To run this application we recommend MySQL and Ruby > 1.8.6 (1.8.7, 1.9.2-p290). Please note the application has not been tested against versions of Ruby later than 1.9.2-p290. This guide assumes that you have RVM installed to manage your Rubies.

## RVM & Rubygems

You'll need to have RVM installed from here on out. If you don't have it you can find install instructions [here](https://rvm.io/).

If you don't already have it then go ahead and grab Ruby 1.9.2:

```bash
rvm install ruby-1.9.2-p290
```

Then switch to that Ruby and create a new gemset for this application:

```bash
rvm 1.9.2-p290@juggernaut --create #note the --create makes a new gemset if you don't already have one.
```

Next you need to grab the gems for the application. Assuming you're in The-Juggernaut checked out repo locally you can do this as follows:

```bash
bundle
```



