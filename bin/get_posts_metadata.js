var glob = require('glob')
var async = require('async')
var fs = require('fs')
var path = require('path')
var yfm = require('yaml-front-matter')
var assert = require('assert')
var moment = require('moment')

module.exports = function(startPath, callback){
  glob(path.join(startPath, '**/index.md'), function(err, mdFiles){
    if (err) return console.error(err.message)
    async.map(mdFiles, function(mdFile, next){
      fs.readFile(mdFile, function(err, data){
        if (err) return next(err)
        var postMeta = yfm.loadFront(data + '')
        postMeta.author = postMeta.author || 'Toby Ho'
        assert(postMeta.title)
        assert(postMeta.date)
        postMeta.path = path.dirname(mdFile).replace(/^contents/, '').toLowerCase() + '/'
        next(null, postMeta)
      })
    }, function(err, posts){
      if (err) return callback(err)
      var published = posts.filter(function(post){
        return post.date instanceof Date
      })
      published.sort(compareByDate)
      callback(null, published)
    })
  })
}

function compareByDate(one, other){
  var oneTs = one.date.getTime()
  var otherTs = other.date.getTime()
  return otherTs - oneTs
}