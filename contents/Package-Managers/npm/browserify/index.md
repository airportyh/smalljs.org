---
title: Browserify
date: 2014-02-02
---
[Browserify](http://browserify.org/) is a build tool that lets you use Node's CommonJS module system for frontend JavaScript development. It integrates seamlessly with [npm](/package-managers/npm), and you can use the same smooth npm workflow for installing and publish modules. For this reason, we've seen the rise of frontend JavaScript modules being published to npm. Browserify also opens up the possibility of code reuse between the server and the client - if you have a Node backend.

To learn more about using npm itself and using it to write server-side Node programs, check out the [npm article](package-managers/npm/).

## The Gist

Pretend you are writing a Node program. You are probably doing these things:

1. Install some modules: `npm install a_module`.
2. Write some code: `vi myprogram.js` (or substitute your favorite editor in place of vi).
3. Test some code: `node myprogram.js`.

With Browserify, you still have these same steps, but you also add a build step, and testing your code involves opening up a browser:

1. Install some modules: `npm install a_module`.
2. Write some code: `vi myprogram.js`.
3. Build the bundle: `browserify myprogram.js -o bundle.js`
3. Test some code: `<script src="bundle.js"></script>`.

And that's Browserify in a nutshell.

## The Walkthrough

Now, a walkthrough for those who like to get their hands dirty. I will go quick because I will assume familiarity with npm.

### Installing

First, you'll need to install Browserify, obviously:

```
npm install browserify -g
```

This should install the browserify executable. On some platforms, you may need to use `sudo` i.e. `sudo npm install browserify -g` if you are getting permission error issues.

### Create A Project

Create a new project directory and create a `package.json` file

```
mkdir browserify_hello
cd browserify_hello
npm init
```

### Grab Some Modules

```
npm install lodash --save
npm install superagent --save
npm install spin --save
npm install dom-events --save
```

## Write Some Code

The following code will implement a Github repository search engine. First, make a `index.html` that contains a basic search UI:

```html
<!doctype html>
<html>
<head>
<title>Browserify Hello</title>
</head>
<body>
  <label for="search">Search Github</label>
  <input id="search" name="search" type="search">
  <button id="button">Search</button>
  <div id="results"></div>
  <script src="bundle.js"></script>
</body>
</html>
```

Next make an `index.js`:

```js
var Spinner = require('spin');
var request = require('superagent');
var event = require('dom-events');
var _ = require('lodash');

var button = document.getElementById('button');
var resultsDiv = document.getElementById('results');
var search = document.getElementById('search');
  
event.on(button, 'click', function(){
  var spinner = new Spinner({
    color: '#000',
    lines: 12
  });
  spinner.spin(resultsDiv);
  request('https://api.github.com/search/repositories')
    .query({q: search.value})
    .end(function(reply){
      renderResults(reply.body);
      spinner.stop();
    });
})

function renderResults(results){
  var div = document.getElementById('results');
  var markup = _.template('<ul>\
    <% _.forEach(items, function(repo){ %>\
      <li><%= repo.full_name %></li>\
    <% }) %>\
  </ul>', results);
  resultsDiv.innerHTML = markup;
}
```

### Bundle It

```
browserify index.js -o bundle.js
```

### Run It

Open `index.html` in you browser, and test it out. You should now have a functioning Github repository search engine, and it even has a spinner while the results are loading!

## Shimmed Node.js Environment

The above example used [lodash](http://lodash.com/), [dom-events](https://github.com/defunctzombie/dom-events), [superagent](https://github.com/visionmedia/superagent), and [spin](https://github.com/visionmedia/spin.js). But you might be wondering: can I use just *any* module off of npm? The answer is: not exactly. Although, Browserify does make a valiant effort.

Browserify makes some modifications to the browser environment to make it look like the Node environment. You have access to things like:

* [process.nextTick()](http://nodejs.org/api/process.html#process_process_nexttick_callback)
* [__dirname](http://nodejs.org/docs/latest/api/globals.html#globals_dirname)
* [__filename](http://nodejs.org/docs/latest/api/globals.html#globals_filename)

You can use Node core modules like:

* [events](http://nodejs.org/docs/latest/api/events.html)
* [stream](http://nodejs.org/docs/latest/api/stream.html)
* [path](http://nodejs.org/docs/latest/api/path.html)
* [assert](http://nodejs.org/docs/latest/api/assert.html)
* [querystring](http://nodejs.org/docs/latest/api/querystring.html)
* [http](http://nodejs.org/docs/latest/api/http.html)

See [the docs](https://github.com/substack/node-browserify#compatibility) for the full list. For a given module, these shims make it much more likely for it to work in the browser, but it's not a guarantee. In practice this is not a big problem, because frontend code and backend code generally do very different things anyway, so it's actually a good idea to keep them separate where it makes sense. But this does present a challenge: *how does one find frontend modules on npm?* Searching on [npm](https://www.npmjs.org/), the only way to know for sure whether a module can work with browserify or not is by installing it and then running Browserify on it. Unfortunately, there's no home-run solution to this yet, but people are working on it and this should get easier soon.

## Source Maps

Since Browserify transforms your source code and dependencies all into one single bundle, debugging can become difficult when you are stepping through the debugger and line numbers that don't correspond to your actual source. Luckily, there's [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/)! To turn on source maps just use the `--debug` option. However, last I checked in Chrome, line numbers in error stack traces still do not get remapped.

## Transforms

Browserify also supports performing source transforms as part of the build process. Using source transforms, you can support preprocessor languages like CoffeeScript, EcmaScript 6 syntax, even markup templating languages like Jade and CSS preprocessor languages like Sass and Less.

For example, to use CoffeeScript, just install the coffeeify module and pass it in via the `-t` option:

```
npm install coffeeify
browserify -t coffeeify index.coffee -o bundle.js
```

Take a look at [the List of Transforms](https://github.com/substack/node-browserify/wiki/list-of-transforms) to see what else is possible with transforms.

## Automation

Having to do a manual compilation step every time you change a file gets old really fast. As you might have guessed, there are tools for that:

* [Grunt-Browserify](https://github.com/jmreidy/grunt-browserify): there's a Grunt plugin for that!
* [vinyl-source-stream](https://github.com/hughsk/vinyl-source-stream) appears to be the prefered solution for Gulp + Browserify.
* [watchify](https://github.com/substack/watchify) - if you just want a standalone watcher.
* [beefy](https://github.com/chrisdickinson/beefy) - spin up a development server that automatically Browserifies your entry point .js file on the fly.
* [bff](https://github.com/airportyh/bff) - like beefy, but doesn't require you to specify an entry point .js.

If you prefer to build your own tooling, Browserify can be used as a Node module:

```js
var browserify = require('browserify');
var fs = require('fs');

browserify(['./index.js'])
  .bundle(function(err, code){
    if (err) return console.error(err.message);
    fs.writeFile('bundle.js', code);
  });
```

## RequireBin: Browserify Playground

Okay, if you are too lazy to even use the automation tools, give [requirebin.com](http://requirebin.com/) a try. It is like a jsbin that integrates with Browserify and npm modules easily. Go there and you can start requiring npm modules right away, and run it. You don't even have to `npm install`.

## jQuery And MV* Frameworks

Although the premise of Small.js is to forego large frameworks in favor of building things from scratch using small modules, I recognize that you can get a lot of benefit from building in small modules atop a larger foundation as well. Plus, this seems to be a common issue people run into, so, I'll cover how Browserify works/interacts with some of the popular frameworks.

* jQuery - `jquery` became a proper npm package starting version 2.0, which means you can `npm install jquery` and `var $ = require('jquery')`, glorious!
* Backbone - `backbone` has long been available on npm, in fact it has proved useful for server-side applications.
* AngularJS, Ember, Marionette and other frameworks not directly available on npm as client packages - I recommend downloading the framework separately either as a direct download or by using bower (to be covered in a separate episode). Include the scripts separately via script tags or via your build process. You can then manage the rest of your dependencies using npm and Browserify by adding another script tag for the browserify bundle.

## Homework

Yes, homework! I can tell you were hoping that I would forget about homework, but I didn't, *ha*!

You homework is to find and discover a new module on npm - one that you did not already know about - install it, and use it with Browserify by building a simple toy application. Have fun!