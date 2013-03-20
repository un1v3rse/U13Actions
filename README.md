# U13Actions

A simple async queue manager for iOS.

Features:

- enqueue asynchronous requests from any thread
- resolve results to main UI thread when required
- support unlimited asynchronous actions within a request, such as authorization

More information in the source-level documentation.  See Documentation below to generate AppleDocs if you prefer.


## Why?

I've spent a bit of time with node.js now, and I was looking for something like a Promise architecture.  After implementing same, I concluded that was a backwards approach for a client, where most actions are initiated by the code, get an immediate response (or progress), and later update.

This code is still a work in progress, I am currently refining it with a real-world application.


## Installation

Copy the project into your source tree.

Include these files in your project by dragging them in:

- U13Action.m/h
- U13ActionQueue.m/h
- U13ActionLog.h

Override `U13ActionQueue` with a class that implements your specific network/authentication needs.

Override `U13Action` with a base class of your own, then override that for each action you want to define for your application.


## Examples

Forthcoming.


## Documentation

Documentation requires installation of [appledoc](https://github.com/tomaz/appledoc)

On your command line, from the root of the project, run:

    ./docs.sh

to generate the docs to a folder named docs.


