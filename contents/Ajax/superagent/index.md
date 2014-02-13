---
title: SuperAgent
date: 2014-02-03
summary:
  github: visionmedia/superagent
  where:
    npm: superagent
    Component: visionmedia/superagent
    Bower: superagent
  supported_browsers: IE6+
  file_size:
    loc: 369
    minified: 
      self: 7.0k
      standalone: 9.9k
  dependencies:
    emitter: https://github.com/component/emitter
    reduce: https://github.com/component/reduce
---
[SuperAgent](http://visionmedia.github.io/superagent/) is a light-weight, flexible and expressive Ajax library.

*Note: SuperAgent has been loaded on this page! You can open up the dev console to try out the examples. The [Github APIs](http://developer.github.com/v3/) support CORS and so you can make Ajax requests to them directly from here.*

## The Basics

All of the examples in SuperAgent's documentation alias SuperAgent to `request`, so I will follow suit. If you are using npm or component

    var request = require('superagent');

If you are using it [standalone](https://github.com/visionmedia/superagent/blob/master/superagent.js)

    var request = window.superagent;

Now, to make a simple `GET` request

    var url = 'https://api.github.com/repos/visionmedia/superagent';
    request.get(url, function(response){
      console.log('Response ok:', response.ok);
      console.log('Response text:', response.text);
    });

The response object is what you get back from the callback.

## Response Object

The response object contains everything you'd need to know about what came back, including:

* `status` - HTTP status, plus meaningful boolean attributes based on it:
  * `ok`
  * `clientError`
  * `serverError`
  * `accepted`
  * `noContent`
  * `badRequest`
  * `unauthorized`
  * `notAcceptable`
  * `notFound`
  * `forbidden`
  * `statusType`
* `text` - unparsed response body string
* `body` - parsed body, only present if response `Content-Type` is "application/json" or "application/x-www-form-urlencoded"
* `header` or `headers` - a map of response headers, note that header names are lowercased
* `error` - an error object if not ok, with details
* `charset` - character set of the response
* `req` - the request object that originated this
* `xhr` - the raw XMLHttpRequest object

Having visited the response object, now let's get into the meat of the library - the *request object*.

## Request Object

Let's step back and look at the request object. A request object is returned by any call to the `request` function or one of its convinience methods - consisting of "get", "post", and other HTTP verbs.

    var req = request.get(url);

If you don't supply a callback function, the request will not be sent out until you called the `end()` method later

    req.end(function(resp){
      console.log('Got response', resp.text);
    });

There are a number of convinience methods too, let's start with query parameters.

## Query Parameters

The `query()` method sets query parameters on the URL of the request.

    req.query({id: 8});

or set it in string format

    req.query('id=8');

You can call it multiple times and it will combine all of the parameters. This makes easy to set parameters conditionally - which is harder to do in jQuery:

    if (search.category){
      req.query({category: search.category});
    }
    if (search.searchTerm){
      req.query({searchTerm: search.searchTerm});
    }

## Method Chaining

In the tradition of jQuery, all methods on the request object are chainable (they return back the request object) to allow for a sort of "fluent syntax".

    request
      .get('/post')
      .query({id: 8})
      .end(function(resp){
        console.log('Got post', resp.body)
      });

## Sending Parameters

Setting parameters on POST or PUT requests works similarly to query parameters, except you use the `send()` method to do it:

    request
      .post('/submit')
      .send({name: 'tj', pet: 'tobi'})
      .end(function(resp){
        // ...
      });

By default, SuperAgent encodes the request body in JSON, which means in this case, you would see a request like

    POST /submit HTTP/1.1
    Host: somesite.com
    Connection: keep-alive
    Content-Length: 26
    ...
    Content-Type: application/json

    {"name":"tj","pet":"tobi"}

You can alternatively use form encoding to mimic submitting an HTML form

    request
      .post('/submit')
      .type('form')
      .send({name: 'tj', pet: 'tobi'})
      .end(function(resp){
        // ...
      });

then the request would be like

    POST /submit HTTP/1.1
    Host: somesite.com
    Connection: keep-alive
    Content-Length: 16
    ...
    Content-Type: application/x-www-form-urlencoded

    name=tj&pet=tobi

## Setting Headers

Setting a header is done with the `set()` method

    req.set('Content-Type', 'application/json');

but if you are setting the `Content-Type`, there's shorthand for that

    req.type('application/json')

there's also a shorthand for setting the `Accept` header

    req.accept('application/json')

## Aborting and Timeouts

You can abort an in-flight request with the `abort()` method. Or more conveniently, the `timeout(ms)` method will abort a request after the specified number of milliseconds has passed without getting a response back.

## Server-Side Capabilities

SuperAgent also works on the server-side. In addition, it has some server-side specific features such as

* Handling redirects
* Piping to streams
* Multipart requests
* Handling attachments
* Compression
* CORS

## Learning More

To learn more about SuperAgent, the best way is to check out [the docs](http://visionmedia.github.io/superagent/).

<script src="superagent.js"></script>