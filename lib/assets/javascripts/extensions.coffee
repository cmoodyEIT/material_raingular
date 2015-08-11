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
