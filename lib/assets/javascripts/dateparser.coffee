root = exports ? this
class root.DateParser
  constructor: (object)->
    @object = object
  formatDate: (date)->
    date.getFullYear() + '-' + ('0' + (date.getMonth() + 1))[-2..-1] + '-' + ( '0' + date.getDate())[-2..-1]
  to_s: ->
    @evaluate(true)
  evaluate: (string_flag)->
    for i of @object
      if @object[i] != null and typeof @object[i] == 'object'
        new DateParser(@object[i]).evaluate()
      else if @object[i] != null and typeof @object[i] == 'string'
        if !!@object[i].match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
          time = new Date(@object[i])
          time.setTime( time.getTime() + time.getTimezoneOffset()*60*1000 ) #offset timezone
          @object[i] = if string_flag then @formatDate(time) else time
        else if !!@object[i].match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T[0-9]{2}\:[0-9]{2}\:[0-9]{2}\.[0-9]{3}[A-Z]$/)
          time = new Date(@object[i])
          @object[i] = if string_flag then @formatDate(time) else time
    return
