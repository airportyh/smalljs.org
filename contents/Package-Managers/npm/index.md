---
title: Introduction to npm
date: 2014-03-19
---
This time on small.js: [npm](https://www.npmjs.org/) - the granddaddy of JavaScript package managers. npm is the beloved package manager for [Node](http://nodejs.org/). It hosts over 64 thousand modules and counting. Based on data at [modulecounts.com](http://modulecounts.com/) - npm is by far the fastest growing package manager, that's is compared to Ruby Gems, CPAN, PyPI, Maven plus a few others. I believe this tremendous rate of growth has everything to do with the ease with which you can write and publish an npm module - we will get to that.

npm isn't limited only to Node modules, however. Client-side JavaScript modules have also found a home on npm. In an upcoming article I will cover how to use client-side modules on npm with [Browserify](http://browserify.org/), but I am getting ahead of myself. First, let's start from the beginning.

## Getting npm

npm comes preinstalled with Node. If you have node, you already have npm! If not, install [Node](http://nodejs.org/) - it's as easy as downloading and then running an installer.

## Installing Modules

npm wants to keep dependencies of different projects separate and isolated - this is a good thing. So first, make a project:

```
mkdir npm_hello
cd npm_hello
```

Now you are ready to install modules! Try this

```
npm install cheerio
```

That installs [cheerio](https://github.com/MatthewMueller/cheerio). Cheerio is a fun module - it gives you a jQuery API for parsing and manipulating a HTML document in Node - without a real browser. For example, the following script (save it as `run.js`) extracts the text within each `<li>` in a HTML snippet:

```js
var cheerio = require('cheerio');
var $ = cheerio.load(
  '<ul>\
    <li>Bob</li>\
    <li>Benny</li>\
  </ul>');

$('li').each(function(){
  console.log($(this).text());
});
```

If you run it, you should get this result:

```
$ node run.js
Bob
Benny
```

Note the thing that you require - the string "cheerio" - is the same as the thing you install on the command line. This is always the case with npm, and it is nice because it removes ambiguity - it's one less thing you have to think about. It also means that if you are reading someone else's script and see `require('abc')`, they almost certainly got it from `npm install abc`.

We are off to a great start. Why not install another one? Let's install [superagent](http://smalljs.org/ajax/superagent/) - which I covered previously.

```
npm install superagent
```

This following script fetchs and prints the titles of latest posts on Hackernews:

```js
var cheerio = require('cheerio');
var request = require('superagent');

request.get('https://news.ycombinator.com/')
  .end(function(reply){
    var $ = cheerio.load(reply.text);
    $('td.title a').each(function(){
      console.log($(this).text());
    });
  });
```

Run that and I got (actual result may vary)

```
[Full-disclosure] Administrivia: The End
Tired of doing coding interviews on Skype? We've built this
The sierpinski triangle page to end most sierpinski triangle pages 
Nodemailer: Easy as cake e-mail sending from your Node.js applications
What Happens to Older Developers?
Needy robotic toaster sells itself if neglected
Cleaning up from an IMAP server failure
... goes on for about 30 more lines ...
```

Look, you just made a web scrapper! Easy right? Such is the power of modules - you can connect them together like legos to make something new and brilliant!

## A Closer Look: Nested Dependencies

If you've been following along, you probably noticed that npm has created a `node_modules` directory inside the project directory. This is where the installed modules reside. A look inside the directory shouldn't surprise you:

```
$ ls node_modules
cheerio
superagent
```

But, you might be wondering, do these modules have any dependencies? If so, where are they? You may remember from the [first Component tutorial](/package-managers/component-part-1/) that Component installs the dependencies of the requested module in the same directory as the requested module. npm does things differently - it installs the dependencies in yet another `node_modules` directory within that module's subdirectory, and this "module nesting" can keep going indefinitely. In our scenario, we have this directory structure:

```
npm_hello
  ├run.js
  └node_modules
    ├cheerio
    │ └node_modules
    │   ├CSSselect
    │   │ └node_modules
    │   │   ├CSSwhat
    │   │   └domutils
    │   │     └node_modules
    │   │       └domelementtype
    │   ├entities
    │   ├htmlparser2
    │   │ └node_modules
    │   │   ├domelementtype
    │   │   ├domhandler
    │   │   ├domutils
    │   │   └readable-stream
    │   │     └node_modules
    │   │       ├core-util-is
    │   │       ├debuglog
    │   │       └string_decoder
    │   └underscore
    └superagent
      └node_modules
        ├cookiejar
        ├debug
        ├emitter-component
        ├extend
        ├formidable
        ├methods
        ├mime
        ├qs
        └reduce-component
```

*That's a lot of modules!* You can also visualize the module dependency hierarchy using `npm list`:

```
$ npm list
.../npm_hello
├─┬ cheerio@0.13.1
│ ├─┬ CSSselect@0.4.1
│ │ ├── CSSwhat@0.4.5
│ │ └─┬ domutils@1.4.0
│ │   └── domelementtype@1.1.1
│ ├── entities@0.5.0
│ ├─┬ htmlparser2@3.4.0
│ │ ├── domelementtype@1.1.1
│ │ ├── domhandler@2.2.0
│ │ ├── domutils@1.3.0
│ │ └─┬ readable-stream@1.1.11
│ │   ├── core-util-is@1.0.1
│ │   ├── debuglog@0.0.2
│ │   └── string_decoder@0.10.25-1
│ └── underscore@1.5.2
└─┬ superagent@0.17.0
  ├── cookiejar@1.3.0
  ├── debug@0.7.4
  ├── emitter-component@1.0.0
  ├── extend@1.2.1
  ├── formidable@1.0.14
  ├── methods@0.0.1
  ├── mime@1.2.5
  ├── qs@0.6.5
  └── reduce-component@1.0.1
```

Note that we can see the version number of each module too. One thing that's interesting to note is that two of the modules installed - `domutils` and `domelementtype` - are duplicates: there are two copies of each of them. That seems redundant and inefficient. *Why does npm do that?* There's actually a good reason - this makes it possible for two or more parent modules to depend on different versions of the same child module. In our scenario, both `cheerio` and `htmlparser2` depend on `domutils`, but `cheerio` uses version 1.4.0 while `htmlparser2` uses version 1.3.0. In general, this ability to load different versions of the same module in different contexts but still within the same app avoids a whole class of problems that have to do with version conflicts - sometimes referred to as [DLL Hell](http://en.wikipedia.org/wiki/DLL_Hell). In the land of Node, there is no DLL Hell, and we all all happier for it. Is it a little less efficient in terms of disk usage? Yes, but disk is cheap, frustration is more expensive - I think this is a worthwhile tradeoff.

## Making It Your Own

Now that you've gotten your feet wet, the next step is to write and publish your own module.

### Setting Up A Module

The one file every module needs is `package.json`. Typing this file out by hand is a little tedious. Fortunately, `npm init` semi-automates this by asking you a series of questions on the prompt. If you are following along, use `<your internet handle>-scrape` as the module name. All fields except for `name` are optional, and you can just hit ENTER to skip them. This is how I answered the prompts 

```
name: (npm_hello) airportyh-scrape
version: (0.0.0) 
description: A simple web scraper.
entry point: (index.js) 
test command: 
git repository: 
keywords: webscrapping
author: Toby Ho
license: (ISC) MIT
```

At the end it displays the resulting `package.json`, and you can go ahead with creating the file or abort. My file looked like this

```js
{
  "name": "airportyh-scrape",
  "version": "0.0.0",
  "description": "A simple webscrapper.",
  "main": "index.js",
  "dependencies": {
    "superagent": "~0.17.0",
    "cheerio": "~0.13.1"
  },
  "devDependencies": {},
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [
    "webscrapping"
  ],
  "author": "Toby Ho",
  "license": "MIT"
}
```

Note that npm automatically added `superagent` and `cheerio` as my module's dependencies because it found them in `node_modules`. *Gee, that's swell, thanks npm!* If you install a module after this point, and would like to add it as a dependency, simply use the `--save` option, as in `npm install <a module> --save`. If you deleted your `node_modules` directory for some reason, you can get all your dependencies back with the command `npm install`.

### Writing The Module

npm also defined `main` - the entry point of the module - to be `index.js`. This is the file Node runs when someone requires the module. Using index.js to mean "top-level entry point" is a common convention, but you can use a different name if you wish. Before creating this file, consider what the API of the module would look like:

```js
var scrape = require('airportyh-scrape');

var url = 'https://news.ycombinator.com/';
scrape(url, 'td.title a', function(err, data){
  // check for err and/or deal with data
});
```

The API should take 3 parameters:

* `url` - the web URL to scrape
* `selector` - the CSS selector to use to find elements of interest on the page
* `callback(err, data)` - a function to be called when the results are ready. It should adhere to Node's [callback convention](http://blog.gvm-it.eu/post/22040726249/callback-conventions-in-node-js-how-and-why) of using the first parameter for errors. The second parameter in the callback is data found and should be an array of strings.

So, here's the `index.js` that implements this:

```js
var cheerio = require('cheerio');
var request = require('superagent');

module.exports = function(url, selector, callback){
  request(url)
    .end(function(err, reply){
      // Node-style error handling and forwarding
      if (err) return callback(err);
      // Also handle/forward error if server returns error
      if (reply.error) return callback(new Error(reply.text));

      // Everything okay, load the HTML
      var $ = cheerio.load(reply.text);

      // Find interesting bits via selector and convert to array
      var data = $(selector).map(function(){
        return $(this).text();
      }).toArray();

      // Pass data back to the callback in second argument
      callback(null, data);
    });
}
```

To test that this worked, modify `run.js` to use it:

```js
var scrape = require('./index');

var url = 'https://news.ycombinator.com/';
var selector = 'td.title a';
scrape(url, selector, function(err, data){
  if (err) 
    console.error(err.message);
    return
  }
  console.log(data.join('\n'));
});
```

Run to verify.

### Go Forth And Publish!

Now you are ready to publish the module! If you've never published a Node module before, you'll need to register for an account on the npm registry, but that's easy:

```
npm adduser
```

This command will ask you for a username, password and your email address. You'd also use this command to login to your existing account in the case that you are on a machine that does not have your npm user information yet.

Next,

```
npm publish
```

Wait... Congratulations! You published your first npm module! If you check the [npm website](https://www.npmjs.org/), you should see yours at or near the top of the "recently updated" list of modules. How does *that* feel?

Now, as an exercise for the reader: make a new test project; install your newly published module from npm, and then write or modify the existing `run.js` to test it.

## Homework

What's that look? You knew you had homework, right? Your assignment is to add a command line utility as part of the module. If a user installs your module globally

```
npm install <your module> -g
```

They should be able to run this command from the shell

```
scrape https://news.ycombinator.com/ "td.title a"
```

and see the results. You'll need to create a `cli.js` in the module, and tell `package.json` about it via the `bin` property. For more information run `npm help json` and look for the "bin" section. You'll also need to inspect the `process.argv` array to get the command line arguments.

## More Info

There's actually a lot more to npm that I haven't covered. Here are some good resources on npm:

* [Tour of npm](http://tobyho.com/2012/02/09/tour-of-npm/)
* [npm Tricks](http://www.devthought.com/2012/02/17/npm-tricks/)
* [How to Build a Node npm Package From Scratch](http://decodize.com/javascript/build-nodejs-npm-installation-package-scratch/)

