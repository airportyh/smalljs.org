---
title: Page
date: 2014-04-17
summary:
  github: visionmedia/page.js
  where:
    npm: page
    Component: visionmedia/page.js
    Bower: page
  supported_browsers: IE8+
  file_size:
    loc: 195
    minified: 
      self: 3.4k
  dependencies: none
---
[Page](https://github.com/visionmedia/page.js) is a small client-side routing library for use with building single page applications (SPAs). It has a simple API which is inspired by [Express](http://expressjs.com/). It utilizes the [HTML5 history API](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history) under the hood, which is what allows you to build smooth user interfaces while still having linkable URLs for different pages of the app.

## Routing

Page supplies you a `page` function which has a few different roles:

```js
var page = require('page');
```

The first of those roles is specifying routes. If you've use Ruby on Rails or Express or a similar framework, this should look familiar:

```js
page('/', function(){
  // Do something to set up the index page
});

page('/about', function(){
  // Set up the about page
});
```

Your routes can contain parameters, which you can assess through the `context` parameter to your route handler

```js
page('/user/:id', function(context){
  var userId = context.params.id;
  console.log('Loading details for user', userId);
});
```

You can use wildcards as parameters too, in which case you will need to use array indexing to access the parameters:

```js
page('/files/*', function(context){
  var filePath = context.params[0];
  console.log('Loading file', filePath);
});
```

A key difference between using a wildcard vs a named parameter is that a wildcard can match the character "/", while a named parameter cannot. In our file path example, using a wildcard allows `filePath` to contain arbitrarily nested subdirectories. 

Another useful thing you can do with a wildcard is to define a fallback route:

```js
page('*', function(){
  console.error('Page not found :(');
});
```

## Starting The Router

Once you have all your routes defined, you need to start the router, which is done with another call to `page`, but this time with no parameters:

```js
page();
```

If you are weirded out by this, and prefer to be more explicit, you can instead write the equivalent:

```js
page.start();
```

Both of these can take an optional `options` object, containing the properties:

* `click` - whether to automatically bind to click events on the page and intercept link clicks and handle them using page's router - defaults to true.
* `popstate` - whether to bind to and utilize the [popstate event](https://developer.mozilla.org/en-US/docs/Web/API/Window.onpopstate) - defaults to true.
* `dispatch` - whether to perform initial route dispatch based on the current url - defaults to true.

## Programmatic Navigation

As mentioned above, page will by default automatically intercept clicks on links on the page and try to handle it using the routes you've setup. Only if it can't match the url with any of the define routes will it default back to the browser's default behavior. Sometimes though, you may want to change the URL based on other events. Maybe the element clicked happens to be something other than a link. Or, if you are building a search page, you may want to allow users to share the URL to their search results. You can do this by just calling `page` function with the page you want to navigate to:

```js
$(form).on('submit', function(e){
  e.preventDefault();
  page('/search?' + form.serialize());
});
```

If you prefer to be more explicit, you can use `page.show(path)` instead.

## Route Handler Chaining

A cool feature of page is that it allows for route handler chaining, which is similar to Express's middlewares. A route definition can take more than one handler:

```js
page('user/:id', loadUser, showUser);
```

Here, when the path `user/1` is navigated, page will first call the `loadUser` handler. When the user is done loading, it will call the `showUser` handler to display it. *How does it know when the user is done loading?* A callback is provided to the handlers as the second parameter - here is what `loadUser` might look like:

```js
function loadUser(ctx, next){
  var id = ctx.params.id;
  $.getJSON('/user/' + id + '.json', function(user){
    ctx.user = user;
    next();
  });
}
```

Then, in `showUser` you can get at the user through `ctx.user`. Now this is nice because you can reuse the `loadUser` function for, say, the `user/:id/edit` route.

## States

The [History API](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history) supports saving states along with each history entry. This allows you to cache information along with previously navigated URLs, so that if the user navigates back to them via the back button, you don't have to to re-fetch the information, making the UI much smoother. Page exposes this via the `state` property of the [context object](https://github.com/visionmedia/page.js#context). To make the above `loadUser` function utilize this cache, you would write this:

```js
function loadUser(ctx, next){
  if (ctx.state.user){
    next();
  }else{
    var id = ctx.params.id;
    $.getJSON('/user/' + id + '.json', function(user){
      ctx.state.user = user;
      ctx.save();  // saves the state via history.replaceState()
      next();
    });
  }
}
```

## Putting It All Together

Now that you know what you need to know about page, let's build an example application. The app will render a list of the earliest Github users. You can click on an individual user and get more details about him or her. The back button should work seamlessly and should use caching. This will use the modules [page](https://github.com/visionmedia/page.js), [superagent](https://github.com/visionmedia/superagent), and [mustache](https://github.com/janl/mustache.js).

```js
var page = require('page');
var request = require('superagent');
var mustache = require('mustache');
```

These are route definitions:

```js
page('/', loadUsers, showUsers);
page('/user/:id', loadUser, showUser);
```

The implementation of `loadUsers` and `loadUser` look like this, much like the previous state-caching example:

```js
function loadUsers(ctx, next){
  if (ctx.state.users){
    // cache hit!
    next();
  }else{
    // not cached by state, make the request
    request('https://api.github.com/users', function(reply){
      var users = reply.body;
      ctx.state.users = users;
      ctx.save();
      next();
    });
  }
}

function loadUser(ctx, next){
  if (ctx.state.user){
    next();
  }else{
    var id = ctx.params.id;
    request('https://api.github.com/user/' + id, function(reply){
      var user = reply.body;
      ctx.state.user = user;
      ctx.save();
      next();
    });
  }
}
```

For rendering the pages, this will use mustache, and I've made the following templates:

```js
var listTemplate = 
  '<h1>Early Github Users</h1>\
  <ul>\
    {{#.}}\
    <li>\
      <a href="/user/{{id}}">{{login}}</a>\
    </li>\
    {{/.}}\
  </ul>';


var showTemplate = 
  '<h1>User {{login}}</h1>\
  <p>{{name}} is user number {{id}}. \
  He has {{followers}} followers, \
  {{public_repos}} public repos and writes a blog at\
  <a href="{{blog}}">{{blog}}</a>.\
  <a href="/">Back to list</a>.</p>\
  ';
```

There are ways to lift the markup into .html files, but I'll save that for another day. To render these templates is job of `showUser` and `showUsers`:

```js
function showUsers(ctx){
  var users = ctx.state.users;

  content.innerHTML = 
      mustache.render(listTemplate, users);
}

function showUser(ctx){
  var user = ctx.state.user;
  content.innerHTML = 
    mustache.render(showTemplate, user);
};
```

And finally, we need to start the router:

```js
page.start();
```

And there you have it! A multi-page single page application. If you want to poke around with this code, take a look at the [full source code](https://github.com/airportyh/page_demo), which has been modularized into small files.