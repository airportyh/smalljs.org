---
title: array
date: 2014-03-26
summary:
  github: matthewmueller/array
  where:
    npm: array
    Component: matthewmueller/array
    Bower: array
  supported_browsers: IE9+
  file_size:
    loc: 419
    minified: 
      self: 6.4k
      standalone: 10.9k
  dependencies:
    emitter: https://github.com/component/emitter
    to-function: https://github.com/component/to-function
    toArray: https://github.com/yields/isArray
---
If you are like me, you had a background in another programming language before getting familiar with JavaScript. Also, if you are like me, the thought "WTF" might have come up once or twice as you were learning JavaScript's [array API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array). Gradually though, you've familiarized yourself with the array, and it has become second nature to you. The array API is actually not that bad, especially after the [functional style methods](http://www.jimmycuadra.com/posts/ecmascript-5-array-methods) were introduced in Ecmascript 5. But still, it *could* be better - which is the aim of the module I am covering - simply called [array](https://github.com/matthewmueller/array). array provides events that allow observers to be notified of changes in the array and adds convinient shorthands for functional style methods.

## The Constructor

First things first: as a convention, we will aliase array's constructor to `array`:

```js
var array = require('array');
```

To make a new array, call the constructor:

```js
var arr = array();
```

Alternatively you can pass an existing native array as its argument and it will initialize to the contents of that array:

```js
var numbers = array([1, 2, 3]);
// => array instance representing [1, 2, 3]
```

Unlike the [native array constructor](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array), you can't pass a variable list of parameters to it or initialize it with a "size" argument:

```js
var arrayOfNames = array("Bob", "Jen", "Ben");
// things will go horribly wrong
var arrayOf5Things = array(5);
// things will also go horribly wrong
```

## Array Methods

array implements most of the [native array methods](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Array) you know and love. In most cases (with some caveat) it can be a drop-in replacement for the native array, but there are also some differences. Later in this article I will list its [differences](#differences-to-native-array) to native arrays.

## Events

Events allow observers to be notified of changes to the contents of the array, which can be useful for building user interfaces. array is an [event emitter](/object/events/event-emitter/), so you can register for change events using the `on()` method

```js
arr.on('change', function(){
  console.log('Array has changed!');
});
```

The following events are emitted:

* `add` (item, index) - when items are added to the array (`push`, `unshift`, `splice`).
* `remove` (item, index) - when items are removed from the array (`pop`, `shift`, `splice`).
* `sort` - when array is sorted.
* `reverse` - when array is reversed.
* `change` - whenever array is modified - emitted at most once for every mutating operation.

## Functional Shorthands

Like the native array, array has the functional programming style helper methods like `map()` and `filter()`, etc (filter is also aliased to `select()`). array adds a twist to them by allowing you to specify the criteria in shorter and more expressive ways than anonymous functions. So instead of writing

```js
var firstNames = users.map(function(user){
  return user.name.first;
});
```

You can write

```js
var firstNames = users.map('name.first');
```

You can use shorthands for filtering an array as well. Here's the before:

```js
users.select(function(user){
  return user.age > 20;
})
```

And here's the after:

```js
users.select('age > 20')
```

Another syntax is:

```js
users.select({age: 14}) // this finds users whose age === 14
```

It does this using the [to-function](https://github.com/component/to-function) behind the scenes - so take a look at to-function to find out all the different ways you can write matchers. Some other methods that support shorthands are:

* `unique(fn|str)` - return a new array whose items are unique wrt to the criteria.
* `reject(fn|str)` - return a new array with all items which match the criteria removed.
* `none(fn|str)` - returns true iff none of the items satisfy the criteria.
* `any(fn|str)` - returns true iff at least one of the items satisfy the criteria.
* `find([fn|str])` - returns the first item that satisfies the criteria or undefined.
* `findLast([fn|str])` - returns the last item that satisfies the criteria or undefined.

For refenence to all methods, take a look at [the docs](https://github.com/matthewmueller/array#iteration-methods).

### `sort()`

The sort method adds some extra shorthand for easily sorting by a criteria. For example, with a native array, if you wanted to sort by the `calories` property of the contained items, you would write a compare function:

```js
function compareCalories(user1, user2){
  if (user1.calories > user2.calories){
    return 1;
  }else if (user1.calories < user2.calories){
    return -1;
  }else{
    return 0;
  }
}
users.sort(compareCalories);
```

With array, you can simply do this:

```js
users.sort('calories');
```

If you want to sort in descending order instead, you can do:

```js
users.sort('calories', 'descending');
```

## Differences To Native Array

Although array's interface mimics the native array for the most part, there are some differences. These are the differences I've found:

* the `length` property doesn't auto-magically update when you set a index of the array beyond it's current size. This shouldn't be a problem because normally, the best practice is to avoid using this feature and use `push` or `splice` to add items.
* doesn't skip holes properly - i.e. `[1, ,3]`.

## More

For more information about [array](https://github.com/matthewmueller/array), visit the [project page](https://github.com/matthewmueller/array).