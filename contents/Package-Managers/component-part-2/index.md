---
title: "Component Part 2: Making Your Own"
date: 2014-02-10
---
*This is our second [Component](https://github.com/component/component/) tutorial - a follow up to the [first](/package-managers/component-part-1).* This article will walk through how to a component. There is a [screencast](#screencast) for this post as well for those who prefer watching over reading.

## Why Make A Component?

Why would one want to make a component? There are mainly two reasons:

1. *Code organization* - breaking up your application into small logical pieces allows other team members and future you navigate the code base more easily.
2. *Code sharing* - if you find that an existing component in your application is applicable in another application you are building, it reduces the build cost of the new application. Furthermore, open sourcing the component opens up the possibility of code reuse with anyone in the world.

With that, let's make a *local component* - for the purpose of code organization; and then we'll make the component public - to share it with the world.

## Setting Up

To set up the project, create a new directory and within it create a `component.json` file with these contents

    {
      "name": "My App",
      "local": [],
      "paths": ["mycomponents"]
    }

The `paths` property tells Component where to search for local components. We've defined `mycomponents` as the subdirectory where they will be located. Let's create this directory:

    mkdir mycomponents

The `local` property is an explicit list of the local components which will be included in the build when we rebuild the components via `component build`. It's empty now because we don't have any yet, so let's make one.

## Making A Local Component

In the [last article](/package-managers/component-part-1), we created a "hello world button" - which when clicked, opens up a dialog box that says "Hello, world!". To refresh your memory, we ended up with this code

    <!doctype html>
    <html>
    <head>
      <title>Hello Dialog</title>
      <link href="build/build.css" rel="stylesheet">
      <script src="build/build.js"></script>
    </head>
    <body>
      <h1>Hello Dialog</h1>
      <button id="button">Open</button>
      <script>
      var Dialog = require('dialog');
      var dom = require('dom');
      dom('#button').on('click', openDialog);

      function openDialog(){
        var dialog = new Dialog('Hello World', 'Welcome human!')
          .closable()
          .modal();
        dialog.show();
      }
      </script>
    </body>
    </html>

The goal is to extract the button into a library so that we can require it, initialize it and attach it to the DOM, like this:

    var HelloButton = require('hello_button');
    var aButton = HelloButton();
    aButton.appendTo(document.body);

We will create a skeleton for the component, use the `component create` command with the `-l` flag - for local.

    component create mycomponents/hello_button -l

This will prompt you for a name, description and a whether it contains JS, CSS, and HTML - we'll say yes to all three.

    $ component create mycomponents/hello_button -l
    name: hello_button
    description: A hello world button.
    does this component have js? ye 
    does this component have css? y
    does this component have html? y

      create : mycomponents/hello_button
      create : mycomponents/hello_button/index.js
      create : mycomponents/hello_button/template.html
      create : mycomponents/hello_button/hello_button.css
      create : mycomponents/hello_button/component.json

Note that some files have been created for you, including a JS file, a CSS file and an HTML file. It also created `mycomponents/hello_button/component.json`. Open it up and we see this

    {
      "name": "hello_button",
      "description": "A hello world button.",
      "dependencies": {},
      "development": {},
      "main": "index.js",
      "scripts": [
        "index.js"
      ],
      "templates": [
        "template.html"
      ],
      "styles": [
        "hello_button.css"
      ]
    }

The `scripts`, `templates` and `styles` properties contain the paths to each file of interest - this is important. A component must explicitly list each Javascript file, template file, and stylesheet file that it needs.

We will put the button's markup in `template.html`.

    <button class="hello_button">Click me!</button>

In `index.js` we will "require" this template file:

    var markup = require('./template.html');

*What?* You can require an HTML file? Why yes. *Yes you can.* During the build step, Component converts HTML files listed as templates to Javascript modules which returns a string containing the markup in the file. The idea is that you can use any templating engine you want to - simply an a build step to compile the template, but component has built-in support for the simplest templating engine of all: plain HTML. Also note that we are using a relative path to require the template - this is necessary when requiring another file within the same component.

To create the button, we use the [dom component](https://github.com/component/dom):

    var dom = require('dom');
    ...
    var button = dom(markup);

We now implement the component by extracting code from the previous example into `index.js`, and exporting a function which creates and returns the button - in the CommonJS module system, this is done by assigning a value to `module.exports`.

    var template = require('./template.html');
    var Dialog = require('dialog');
    var dom = require('dom');

    module.exports = function(){
      var button = dom(template)
        .on('click', openDialog);
      return button;
    }

    function openDialog(){
      var dialog = new Dialog('Hello World', 'Welcome human!')
        .closable()
        .modal();
      dialog.show();
    }

Create a new test page

    <!doctype html>
    <html>
    <head>
      <title>Hello Dialog</title>
      <link href="build/build.css" rel="stylesheet">
      <script src="build/build.js"></script>
    </head>
    <body>
      <h1>Hello Dialog</h1>
      <script>
      var HelloButton = require('hello_button');
      var aButton = HelloButton();
      aButton.appendTo(document.body);
      </script>
    </body>
    </html>

If you rebuild and load the page now, you'll get errors. There are two issue. First we need to specify the parent project's dependency on "hello_button". Also since it no longer directly require component/dom and component/dialog - those can be removed. Add "hello_button" to the main project's "local" property, like so:

    {
      "name": "hello_component",
      "paths": ["mycomponents"],
      "local": ["hello_button"],
      "dependencies": {}
    }

Next, establish hello_button's dependency on component/dom and component/dialog: in `mycomponents/hello_button/component.json` make sure you have:

    ...
    "dependencies": {
      "component/dom": "*",
      "component/dialog": "*"
    },
    ...

Re-install and then rebuild everything in the parent project directory

    component install
    component build

Reload the page and thing should work just like before.

We have yet to make use of the CSS file in the hello_button component, so let's do that. Let's make this button fancy! In `mycomponents/hello_button/styles.css` put

    button.hello_button{
      color: red;
      font-family: Impact;
      font-size: 2em;
      background-color: green;
      border: 5px solid red;
    }

Rebuild

    component build

Aaaand BAM! Colors.

![Hello Button](./button.png)

## Auto-Rebuilding

During the course of building this component, you might have had to type `component build` quite a few times. This gets tedious, doesn't it? Tj recommends using a C program called [watch](https://github.com/visionmedia/watch), which simply reruns a supplied command every second. To install it

    git clone git@github.com:visionmedia/watch.git
    cd watch
    make install

This installs the `watch` command, and you can now do `watch component build` from the project directory in a separate terminal, and not have to manually rebuild.

## Making It Public

If you had wanted to make a public component in the beginning, you would have used the `component create` command without the `-l` flag - which will scaffold out some extra things for you in the project. But since we already have a working local component, we'll just convert it to a public component.

The main things you need for a public component which are not already present in a local component are

1. "repo" property in `component.json` - the Github repo path of the component.
2. "version" property in `component.json` - a version number becomes important when code becomes public and others depend on it.
3. "license" property in `component.json` - the open source license the component is under.
4. A README.md file.
5. All dependencies of the component must also be public components.

We'll move the component outside of the parent project:

    mv mycomponents/hello_button ../hello_button
    cd ../hello_button

Edit the `component.json` to add some fields to it (replace `<github user>` with your own Github username):

    ...
      "repo": "<github user>/hello_button",
      "version": "0.0.1",
      "license": "MIT",
    ...

Next add a `README.md` (follow this or use your imagination):

    Hello Button
    ============

    A hello world button.

    ## Install

        component install <github user>/hello_button

    ## Usage

    ``` js
    var HelloButton = require('hello_button');
    var button = HelloButton();
    button.appendTo(document.body);
    ```

All dependencies of the button component are already public (component/dialog and component/dom), so we are good there. Now we are ready to publish! [Create a new repo](https://github.com/new) on Github and call it `hello_button`. Then back in the terminal:

    git init
    git add .
    git commit -m "First commit"
    git remote add origin git@github.com:<github user>/hello_button.git
    git push -u origin master

Voila! You've created your first component. But let's make sure it works okay by installing within the parent project. Go back to the parent project, and remove "hello_button" from the "local" property of `component.json`. If you `component build` and reload the page, it should fail. Now, install your new public component

    component install <github user>/hello_button
    component build

Reload the page now, and it should work as before!

## Adding It To The Registry

If this component were any useful, the next step would be to add it to the [Components Registry](https://github.com/component/component/wiki/Components) so that other people can find it. The registry is nothing but a wiki, so to add an entry amounts to clicking "Edit Page", adding a link to your component's project repo, and writing a brief description.

## Screencast

Here's this post in screencast form - *get your popcorn*!
<iframe src="//player.vimeo.com/video/86339228" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="http://vimeo.com/86339228">Component Part 2</a> from <a href="http://vimeo.com/user1147567">Toby Ho</a> on <a href="https://vimeo.com">Vimeo</a>.</p>