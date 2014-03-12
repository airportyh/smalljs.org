---
title: Event Emitter
date: 2014-02-18
---
<div class="summary">
  <h3>Module Summary</h3>
  <dl>
    <dt>Node.js:</dt>
    <dd>[events](http://nodejs.org/api/events.html)</dd>
    <dt>Component:</dt>
    <dd>[component/emitter](https://github.com/component/emitter)</dd>
    <dt>Bower:</dt>
    <dd>[eventEmitter](https://github.com/Wolfy87/EventEmitter)</dd>
    <dt>Dependencies:</dt>
    <dd>None</dd>
    <dt title="lines of code with comments and empty lines stripped">LOC:</dt>
    <dd title="lines of code with comments and empty lines stripped">
      <span title="Node built-in version">302</span>/<span title="Component version">112</span>/<span title="Bower/Wolfy87 version">308</span>
    </dd>
    <dt>File size minified:</dt>   
    <dd>
      <span title="Node built-in version">4.2k</span>/<span title="Component version">1.3k</span>/<span title="Bower/Wolfy87 version">2.8k</span>
    </dd> 
  </dl>
</div>

Today I am going to cover the *event emitter*. What is an event emitter? Well, it's a simple library for attaching events to JavaScript objects. 

## A Little History

Event emitter first appeared as a [core library](http://nodejs.org/api/events.html) in Node where it has proven to be a useful pattern. Since the library itself is not specific to Node at all, it has found uses in the browser as well. There are now many implementations of event emitter - partly due to how easy it is to implement its API. Here, I am going to cover the event emitter API that is common to most implementations.

## Registering

Let's say there is `job` object which happens to be an event emitter. To register an event handler for the event `done`, you'd use the `on` method like so:

``` js
job.on('done', function(){
  console.log('The job is done!');
});
```

## Emitting

Now if you are writing the code responsible for actually performing the job, you'll need to notify all the handlers that the job was done at the end. How do you do that?

``` js
job.emit('done');
```

You can also pass arguments to the event, for example the time when the job was done.

``` js
var timeDone = new Date();
job.emit('done', timeDone);
```

The arguments will passed in the same order to all the handlers.

``` js
job.on('done', function(timeDone){
  console.log('Job was pronounced done at', timeDone);
});
```

## Removing Handlers

To remove an active event handler from an event emitter, you'd use the `removeListener` method

``` js
function onDone(timeDone){
  console.log('Job was pronounced done at', timeDone);
}
job.on('done', onDone);
...
job.removeListener('done', onDone);
```

Or you could use the `removeAllListeners` method to remove all handlers associated with an event:

``` js
job.removeAllListeners();
```

## Fire Just Once

The event emitter API also has a convinient shorthand for registering a handler to be called once, and once only, it's called `once()`.

``` js
job.once('done', function(){
  // This callback will only be called the
  // first time `done` is fired.
});
```

## Make Your Own Event Emitter

So, that's great, but how do you make an event emitter of your own? You inherit EventEmitter.

``` js
function Job(){
  EventEmitter.call(this);
  // custom initialization here
}
Job.prototype = new EventEmitter;
```

I find that this is the simplest way to inherit EventEmitter without using any utilities. To make it even simpler, the line `EventEmitter.call(this)` is not strictly necessary since EventEmitter`s constructor doesn't do anything - but people have been told to add this in just in case it ever does in the future.

There are other flavors of inheriting EventEmitter. I will list them here in case you encounter them and get confused. So, in place of `Job.prototype = new EventEmitter`, you could also:

1. Use an inheritance function like [Node's util.inherits](http://nodejs.org/api/util.html#util_util_inherits_constructor_superconstructor) or [component/inherit](https://github.com/component/inherit):
        inherit(Job, EventEmitter)
2. Use `__proto__` but this is is not supported in IE 10 and older (I am partial to this one if I am doing Node-only stuff):
        Job.prototype.__proto__ = EventEmitter.prototype
3. Mixin instead of inherit, i.e. copy over the methods, with an extend function like [xtend](https://github.com/Raynos/xtend) or [_.extend](http://underscorejs.org/#extend) or just write your own:
        extend(Job.prototype, EventEmitter.prototype)
4. Built-in mixin capability as implemented by [component/inherit](https://github.com/component/inherit)
        EventEmitter(Job.prototype)

Regardless of which of the above you use, you can create a job with the `new` operator

``` js
var job = new Job
```

and it is indeed an event emitter!

## Where To Get It?

* Node/Browserify - it's built in.
        var EventEmitter = require('events').EventEmitter
* Component - use [component/emitter](https://github.com/component/emitter).
* Bower or standalone - use [Wolfy87/EventEmitter](https://github.com/Wolfy87/EventEmitter).

Some implementations have more extra features, but they will all support the basic features covered above.