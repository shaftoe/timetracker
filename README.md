# TTrack (TimeTracker)

## Disclaimer

These are my very first lines of Ruby, and this is purely meant to be a make-your-feet-wet
project, so clone this stuff only if you want to read some very ugly Ruby code

## What I ask to TimeTracker

I want to write a very simple piece of software that lets me easily keep track of time spent
on given issues. Once it works from CLI, a bonus could be to have an easy way to sync this
timesheets to some external PM software like Redmine via REST APIs

## How to use

Install TTrack

	$ gem install ttrack

Initialize sqlite3 db (defualted to $HOME/.timetrackerdb)

	$ ttrack
	$ ls ~/.timetrackerdb

Start tracking an issue

	$ ttrack start my_issue

Check current tracked issue's status

	$ ttrack status

Stop tracking...

	$ ttrack stop

... or just start tracking a new issue

	$ ttrack start my_new_issue

Get a list of tracked issues

	$ ttrack report

Get a report for a particular issue name

	$ ttrack report my_issue

Edit start and/or stop time for a given issue *number* (use UTC timestamps)

	$ ttrack report
	$ ttrack beguin <issue_number> 2011-01-01 00:00
	$ ttrack end <issue_number> 2011-01-02 00:00:59
