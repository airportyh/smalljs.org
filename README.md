Small.JS The Blog
=================

This repository contains the content and the code for generating the website for [smalljs.org](http://smalljs.org).

## Building

Prerequisites:

1. Node
2. Make

To build run:

    npm install
    make

## Setting Up Development On Windows

Setting up development on Windows will require you to install [Cygwin](http://www.cygwin.com/).

### Install Cygwin

1. Install Cygwin, Run the `setup-x86.exe` if you have a 32 bit machine, or `setup-x86_64.exe` if you have a 64 bit machine.
2. Choose download site: I recommend the `ftp.gtlib.gatech.edu` for the down load site.
3. Select Packages: Open up the `Devel` group, select `Make` from the list if it's not been selected.
4. Continue with the install, it make take a couple of minutes.

### Install Node

Install <http://nodejs.org>.

### Install Git

Install [git for windows](http://msysgit.github.io/), go with the latest version.

### Run The Build

Open a cygwin window, clone the repository

```
git clone https://github.com/airportyh/smalljs.org.git
```

This should create a `smalljs.org` directory. Change into it

```
cd smalljs.org
```

Run

```
npm install
make
```

## Contributing

Send me a pull request! Or, if you are unsure about the topic, open an issue and we'll chat.