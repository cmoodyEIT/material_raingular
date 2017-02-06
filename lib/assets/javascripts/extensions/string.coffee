String.prototype.to_number = ->
  Number(this)
String.prototype.to_string = ->
  this.toString()
String.prototype.to_date = ->
  new Date(this)
String.prototype.titleize = ->
  return this.replace(/\_/g,' ').replace(/([A-Z])/g, ' $1').trim().replace(/\b[a-z]/g, (letter)->
    return letter[0].toUpperCase())
String.prototype.to_f = ->
  return parseFloat(this)
String.prototype.to_i = ->
  return parseInt(this)
