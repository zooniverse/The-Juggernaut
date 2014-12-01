Juggernaut
================

[![Build Status](https://travis-ci.org/zooniverse/The-Juggernaut.png)](https://travis-ci.org/zooniverse/The-Juggernaut)

# Getting Started

To run this application we recommend MySQL and Ruby > 1.8.6 (1.8.7, 1.9.2-p290). Please note the application has not been tested against versions of Ruby later than 1.9.2-p290. This guide assumes that you have RVM installed to manage your Rubies. You'll also need a JavaScript runtime.

## RVM & Rubygems

You'll need to have RVM installed from here on out. If you don't have it you can find install instructions [here](https://rvm.io/).

If you don't already have it then go ahead and grab Ruby 1.9.2:

```bash
$ rvm install ruby-1.9.2-p290
```

Then switch to that Ruby and create a new gemset for this application:

```bash
$ rvm 1.9.2-p290@juggernaut --create #note the --create makes a new gemset if you don't already have one.
```

Next you need to grab the gems for the application. Assuming you're in The-Juggernaut checked out repo locally you can do this as follows:

```bash
$ bundle
```

## Configuring the database

Next we need to set up the database for the application. The configuration is in config/database.yml and by default is set up as follows:

```yaml
development:
  adapter: mysql2
  host: localhost
  username: root
  password: 
  database: the_juggernaut_development

test:
  adapter: mysql2
  host: localhost
  username: root
  password: 
  database: the_juggernaut_test
```

Modify these settings for your particular setup (username/password) and when you're ready to create your databases and set up the database structure run the following:

```bash
$ rake db:create
$ rake db:schema:load
```

## Booting the application

Provided all of the previous steps have run without error you should now be able to boot the application screen by executing the standard Rails boot:

```bash
$ rails server
```

Checking in on [http://0.0.0.0:3000](http://0.0.0.0:3000) you should see a page render with the message:

> '_You need to log in · Would you like to classify some images?_'

## Setting up a workflow

By default there are no images ([Subjects](https://github.com/zooniverse/The-Juggernaut/blob/master/app/models/subject.rb)) available to be classified. To test out the functionality you need to bootstrap the application with a test workflow based on the Galaxy Zoo Hubble decision tree. You can instantiate that as follows:

```bash
$ rake workflow:execute[hubble]
```

Here, `hubble` corresponds to the [lib/workflows/hubble.rb](https://github.com/zooniverse/The-Juggernaut/blob/master/lib/workflows/hubble.rb) workflow script. This gives an excellent example of the sort of questions and answers you can supply to a Juggernaut workflow. To create your own, you can use:

```bash
$ rake workflow:create[NAME]
```

or simply create `NAME.rb` in `lib/workflows`, add your questions and answers, and execute it with:

```bash
$ rake workflow:execute[NAME]
```

## Loading the test subjects

By default there are 4 images included with the application to help test out the Hubble Workflow. There's also a rake task you can run that should import these.

```bash
$ rake subjects:load[test_subjects]
```

Note that this task assumes that the id (in the database) for the Hubble workflow is '1'. If this is not the case then you'll need to edit this task to get the application working.


##Running the Juggernaut

You should now be able to run the Juggernaut with the Hubble workflow and classify the four test subjects:

```bash
$ rails server
```

(Open [http://localhost:3000](http://localhost:3000) in your browser and log in with your Zooniverse ID.)


##Clearing the subjects, workflows, and classifications

Before trying to add your own subjects and workflows, you'll probably want to remove the test items and any classifications you've made. This can be done with:

```bash
$ rake classifications:clear

Clearing classifications and favourites...
...done.

$ rake workflow:clear
This will destroy all workflows, tasks, and answers in the development environment
Are you sure you want to do this? (y/n)
y
Destroying...
Done
$ rake subjects:clear[test_subjects]
[OUTPUT]
```

where `OUTPUT` will tell you what's happened (i.e the subjects have been removed). You're now ready to try...


##Adding your own subjects

Firstly, you'll need to copy your set of images into a directory in `app/assets/images`:

```bash
$ mkdir app/assets/images/my_subjects
$ cp $MYSUBJECTS/*.png app/assets/images/my_subjects/.
```

You can then use the same `rake` task used above to load them into the database:

```bash
$ rake subjects:load[my_subjects]
```

You _could_ use the Hubble workflow to classify them... but you'll probably want to create your own workflow as described above and execute it with:

```bash
$ rake workflow:execute[my_workflow]
```

You can then run the Juggernaut exactly as before - this time with your own subjects and classification system!


## You're done!

That's about it. At this point you should have a working application saving classifications and annotations to the database and the option to favourite items during classification. Congratulations!
