Array.prototype.min = ->
  return Math.min.apply(null,this)
Array.prototype.max = ->
  return Math.max.apply(null,this)
Array.prototype.sum = ->
  total = 0
  for i in this
    total += parseFloat(i) if i
  total
Array.prototype.includes = (entry)->
  this.indexOf(entry) > -1
Array.prototype.drop = (entry)->
  this.splice(this.indexOf(entry),1)
String.prototype.titleize = ->
  return this.replace(/\_/g,' ').replace(/\b[a-z]/g, (letter)->
    return letter[0].toUpperCase())
