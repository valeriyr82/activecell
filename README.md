<pre>
	                        (                             (     (     
   (        (     *   ) )\ )                (         )\ )  )\ )  
   )\       )\  ` )  /((()/( (   (   (      )\   (   (()/( (()/(  
((((_)(   (((_)  ( )(_))/(_)))\  )\  )\   (((_)  )\   /(_)) /(_)) 
 )\ _ )\  )\___ (_(_())(_)) ((_)((_)((_)  )\___ ((_) (_))  (_))   
 (_)_\(_)((/ __||_   _||_ _|\ \ / / | __|((/ __|| __|| |   | |    
  / _ \   | (__   | |   | |  \ V /  | _|  | (__ | _| | |__ | |__  
 /_/ \_\   \___|  |_|  |___|  \_/   |___|  \___||___||____||____| 
</pre>

**Activecell** is the small business management platform. With Activecell, a small business owner can quickly and easily build a dynamic financial plan that connects to their accounting data for historical analysis. 

## Requirements

Activecell's git repo is available on GitHub, which can be browsed at:

    <http://github.com/activecell/activecell>

and cloned with:

    git clone git://github.com/activecell/activecell.git

Please use `script/bootstrap` to automatically check for current requirements.

## Contributing

To contribute to Activecell, please follow these instructions.

1. Clone the project with `git clone git://github.com/activecell/activecell.git`
1. Run `script/bootstrap` to check for requirements
1. Run `rake` to ensure from the beginning that tests pass on your machine
1. Create a thoughtfully named topic branch to contain your change
1. Hack away
1. Add specs and make sure everything still passes by running 'rake'
1. If necessary, [rebase your commits into logical chunks](https://help.github.com/articles/interactive-rebase), without errors
1. Push the branch up to GitHub
1. Send a pull request for your branch

Please (please please please) read our [Quality](https://github.com/profitably/active_cell/wiki/Quality) page on the wiki for more details about acceptance criteria for code and testing.

### Reserved branch: master

1. **master** is linked to our staging server. _**All tests on master branch must pass**_. If you commit to master and a test fails, that's priority #1. Either hotfix it or roll back. When you commit to origin/master, it will automatically push changes to jenkins for continuous integration, and if tests pass, it will _**automatically deploy to staging**_.

Please make sure nothing goofy is in this branch! Commits may be merged by engineers down to feature branches at any time!

## Profitably "flow"

### Bugs and new features in [Github Issues](https://github.com/activecell/activecell/issues) 

* Urgency
** ASAP bugs are more urgent than new functionality
** When a bug is assigned to you in the ASAP milestone please try to close it out with a fix as soon as possible
* Committing
** Please squash commits into a coherent solution, per <http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html>
** Please title your commit to close the ticket (e.g. "Fixes #252") so the commit is linked to the issue

### Group chat and realtime activity stream in [HipChat](https://profitably.hipchat.com/home)

* Hipchat is great for both group and private conversations
* Chatting in hipchat's "Dev" room rather than private rooms or skype means that others can view the conversation later to get caught up on the ongoing discussions
* Integrations
** Github, pivotal, jenkins, heroku, and UserVoice all push their activity stream to hipchat for our viewing pleasure

### Continuous integration with [tddium](https://www.tddium.com)

* per above, pushing to origin/master will automatically push to our staging environment if tests pass

### Customer engagement (support and feedback) in [UserVoice](http://feedback.profitably.com/)

* ...more to come...

## Gotchas

### Run the application with foreman in the development mode

```
foreman start -f Procfile.development
```

This command will start the following services:

* rails server (http://launchpad.activecell.local)
* resque background worker (http://launchpad.activecell.local/resque)
* mailcatcher (http://localhost:1080)

### Running specs with spin

Spin speeds up your Rails testing workflow by preloading your Rails environment. It's an unobrustive alternative to spork.

Some usages:

* run the server

```
spin serve
```

* push test examples

```
spin push spec/models/user_spec.rb
spin push spec/models/user_spec.rb:14
```

* or use it with guard

```
guard
```

This command will automatically manage spin server and push examples for changed files.

### Speed up tests with parallel_tests

Without parallel: **Finished in 2 minutes 42.21 seconds**

With parallel: **Took 55.792039342 seconds**

* if you want to execute all specs (in paraller)

```
rake parallel:spec
```

* if you want to execute all specs for API (in parallel)

```
bundle exec parallel_rspec spec/ -n 8 -o '--tag api'
```

* run specs from the given directory

```
rake parallel:spec[^spec/lib/etl]
```
