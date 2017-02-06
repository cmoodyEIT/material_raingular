Object.reject = (obj,arg) ->
  res = {}
  for key,val of obj
    unless typeof arg == 'function'
      res[key] = val unless [arg].flatten().includes?(key)
    else
      temp={}
      temp[key] = val
      res[key] = val unless arg(key,val,temp)
  res

Object.select = (obj,arg) ->
  res = {}
  for key,val of obj
    unless typeof arg == 'function'
      res[key] = val if [arg].flatten().includes?(key)
    else
      temp={}
      temp[key] = val
      res[key] = val if arg(key,val,temp)
  res
