---
title: JSDiff
date: 2014-04-10
---
[JSDiff](https://github.com/kpdecker/jsdiff) is an implementing of text comparison in Javascript, it is used in Mocha to implement [colored diffs](http://visionmedia.github.io/mocha/#string-diffs), and it's fairly easy to use.

Let's say you have two strings: `oldString` and `newString`

```js
var oldString = 'beep boop';
var newString = 'beep boob blah';
```

To compare them you may use the `diffChars` method

```js
var diff = JsDiff.diffChars(oldString, newString);
```

This gives you `diff` which is an array of change objects. A change object represents a section of text which is has either been added, removed, or neither. It has the following properties

* `value`: text content
* `added`: whether the value was inserted into the new string
* `remove`: whether the value was removed from the old string

In the above example, if you'd log the `diff` object, you'd see

```js
[ { value: 'beep boo', added: undefined, removed: undefined },
  { value: 'b blah', added: true, removed: undefined },
  { value: 'p', added: undefined, removed: true } ]
```

To render this information visually, we can color code these text chunks. In Node, there's a module [colors](https://github.com/Marak/colors.js) which makes outputing colors to the terminal easy.

```js
diff.forEach(function(part){
  // green for additions, red for deletions
  // grey for common parts
  var color = part.added ? 'green' :
    part.removed ? 'red' : 'grey';
  process.stderr.write(part.value[color]);
});
```

If you run this program ([see full source code](https://github.com/airportyh/jsdiff/blob/docs/examples/node_example.js)) you should see

<img src="node_example.png">

You can also use [JSDiff](https://github.com/kpdecker/jsdiff) on a web page by using browserify or just via `<script>` tag. To render the same diff using DOM elements - using the raw DOM API would look like

```js
var display = document.createElement('pre');
diff.forEach(function(part){
  // green for additions, red for deletions
  // grey for common parts
  var color = part.added ? 'green' :
    part.removed ? 'red' : 'grey';
  var span = document.createElement('span');
  span.style.color = color;
  span.appendChild(document
    .createTextNode(part.value));
  display.appendChild(span);
});
document.body.appendChild(display);
```

The result of that code ([full source](https://github.com/airportyh/jsdiff/blob/docs/examples/web_example.html), or [on requirebin](http://requirebin.com/?gist=7325660)) would look like

<img src="web_example.png">

But wait, there's more. Take a look at JsDiff's [API](https://github.com/kpdecker/jsdiff#api), it can also

* compare by word.
* compare by line.
* compare CSS.
* create patch files for use with the [patch](http://en.wikipedia.org/wiki/Patch_\(Unix\)) program.

*This article was originally posted at <http://tobyho.com/2013/11/05/jsdiff-for-comparing-text/>.*