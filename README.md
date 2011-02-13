#Fluttrly-gem

##What is this?
Fluttrly-gem is a command line gem I decided to make to help contribute to
[fluttrly](http://github.com/excid3/fluttrly).


##Why?
I wanted to know how to write gems with the new way bundler makes them, and I saw
[Holman](http://github.com/holman) make [boom](http://github.com/holman/boom). So I wanted to make a
command line utility myself. Sweet!


##Disclaimer
If you somehow get hurt using this. You're retarded. That being said, I shipped this as soon as possible,
so not all of the features are done yet. Also, by shipping as soon as possible I realize there's much
to be refactored.


##Usage
** List an item **
    #fluttrly <command> <list>
    $ fluttrly list bouverdafs
    Task => "Nothing to see here, move along" at => 02-08-2011 18:57 PM 

** Post an item **
    #fluttrly <command> <list> <message>
    $ fluttrly post bouverdafs "gem'd"
    $ fluttrly list bouverdafs
    Task => "gem'd" at => 02-10-2011 16:18 PM 
    Task => "Nothing to see here, move along" at => 02-08-2011 18:57 PM 
    
** Update a task **
    #fluttrly <command> <list>
    $ fluttrly edit bouverdafs
    1: Task => "gem'd" at => 02-10-2011 16:18 PM (Completed? false)
    2: Task => "Nothing to see here, move along" at => 02-08-2011 18:57 PM (Completed? false)
    Which item would you like to edit?
    1
    fluttrly list bouverdafs
    1: Task => "gem'd" at => 02-10-2011 16:18 PM (Completed? true)
    2: Task => "Nothing to see here, move along" at => 02-08-2011 18:57 PM (Completed? false)
    
    

    
##Install 
    $ gem install fluttrly

##TO DO
* Tom-doc this ish
* Removing items completely (1 or many)
* Adding to locked lists :\


