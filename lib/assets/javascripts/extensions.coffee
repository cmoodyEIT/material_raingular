Array.prototype.empty = ->
  this.length == 0
Array.prototype.present = ->
  this.length != 0
Array.prototype.min = ->
  return Math.min.apply(null,this)
Array.prototype.max = ->
  return Math.max.apply(null,this)
Array.prototype.railsMap = (func)->
  args = func.match(/\|(.*)\|,(.*)/) || []
  throw 'Invalid syntax "|a|, a.b"' unless args.length == 3
  arr = []
  for obj in this
    eval args[1] + '= obj'
    arr.push eval "(" + args[2] + ")"
  arr
Array.prototype.compact = ->
  arr = []
  for i in this
    arr.push(i) if !!i or i == false
  arr
Array.prototype.flatten = ->
  arr = []
  for l in this
    if Array.isArray(l)
      for i in l.flatten()
        arr.push i
    else
      arr.push l
  arr
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
  return this.replace(/\_/g,' ').replace(/([A-Z])/g, ' $1').trim().replace(/\b[a-z]/g, (letter)->
    return letter[0].toUpperCase())
Array.prototype.pluck = (property) ->
  return [] if !(this && property)
  property = String(property)
  return this.map (object) ->
    object = Object(object)
    return object[property] if (object.hasOwnProperty(property))
    return ''
Array.prototype.unique = (filterOn) ->
  equiv = (first,second) ->
    return true if first == second
    return !first && !second
  newItems = []
  for item in this
    item = item[filterOn] if filterOn
    for newItem in newItems
      isDuplicate = false
      if equiv(item,newItem)
        isDuplicate = true
        break
    newItems.push(item) if (!isDuplicate)
  return newItems
String.prototype.to_f = ->
  return parseFloat(this)
String.prototype.to_i = ->
  return parseInt(this)
Array.prototype.dup = ->
  return @.slice(0)
Array.prototype.where = (obj) ->
  equiv = (first,second) ->
    return true if first == second
    if !isNaN(first) && !isNaN(second)
      return true if parseFloat(first) == parseFloat(second)
    return false
  result = []
  for entry in @
    addEntry = true
    for key,value of obj
      addEntry = addEntry && equiv(entry[key], value)
    result.push(entry) if addEntry
  result
