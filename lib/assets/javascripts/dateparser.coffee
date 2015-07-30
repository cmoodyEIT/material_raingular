root = exports ? this
class root.DateParser
  constructor: (object)->
    @object = object
  evaluate: ->
    for i of @object
      if @object[i] != null and typeof @object[i] == 'object'
        new DateParser(@object[i]).evaluate()
      else if @object[i] != null and typeof @object[i] == 'string'
        if !!@object[i].match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
          time = new Date(@object[i])
          time.setTime( time.getTime() + time.getTimezoneOffset()*60*1000 ) #offset timezone
          @object[i] = time
        else if !!@object[i].match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T[0-9]{2}\:[0-9]{2}\:[0-9]{2}\.[0-9]{3}[A-Z]$/)
          @object[i] = new Date(@object[i])
    return
