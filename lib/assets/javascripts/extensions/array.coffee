Array::dup        =       -> return @slice(0)
Array::empty      =       -> @length == 0
Array::first      =       -> @[0]
Array::intersects = (arr) -> @intersection(arr).length > 0
Array::last       =       -> @[@length - 1]
Array::min        =       -> return Math.min.apply(null,@)
Array::max        =       -> return Math.max.apply(null,@)
Array::present    =       -> @length != 0
Array::remove_all =       -> @splice(0,@length)

Array::add = (arr) ->
  (@push(item) unless @includes(item)) for item in arr
  @
Array::allIndicesOf = (arg) ->
  res = []
  until res.last() == -1 || res.length > 10
    start = if (res.last() > -1) then res.last() + 1 else 0
    res.push(@indexOf(arg,start))
  res[0..-2]
Array::compact = ->
  arr = []
  (arr.push(i) if !!i or i == false) for i in @
  arr
Array::drop = (entry)->
  if (entry || {}).hasOwnProperty('id')
    index = @pluck('id').indexOf(entry.id)
  else
    index = @indexOf(entry)
  return @ unless index > -1
  @splice(index,1)
Array::find = (id) ->
  index = @pluck('id').indexOf(id)
  @[index]
Array::flatten = ->
  arr = []
  for l in @
    if Array.isArray(l)
      for i in l.flatten()
        arr.push i
    else
      arr.push l
  arr
Array::includes = (entry)->
  return @indexOf(entry) > -1 unless entry
  if entry instanceof Date
    (@map (obj) -> obj?.toDateString?()).includes(entry.toDateString())
  else if entry.hasOwnProperty('id')
    return @pluck('id').includes(entry.id)
  else
    return @indexOf(entry) > -1
Array::index = (obj) ->
  return unless (obj || {}).hasOwnProperty('id')
  @pluck('id').indexOf(obj.id)
Array::$inject = (action) ->
  operators = {
    '+': (a,b) -> a + b
    '-': (a,b) -> a - b
    '*': (a,b) -> a * b
    '/': (a,b) -> a / b
    '&': (a,b) -> a && b
    '|': (a,b) -> a || b
    'merge': (a,b) ->
      res = new Object(a)
      res[key] = value for key,value of b
      res
  }
  result = null
  for item,index in @
    result ||= item
    continue if index == 0
    result = operators[action](result,item)
  result
Array::intersection = (arr) ->
  res = []
  (res.push(val) if arr.includes(val)) for val in @
  return res
Array::merge = (arg) ->
  @push(i) for i in arg
  @
Array::pluck = (property) ->
  return [] if !(@ && property)
  property = String(property)
  return @map (object) ->
    object = Object(object)
    return object[property] if (object.hasOwnProperty(property))
    return ''
Array::railsMap = (func)->
  args = func.match(/\|(.*)\|,(.*)/) || []
  throw 'Invalid syntax "|a|, a.b"' unless args.length == 3
  arr = []
  for obj in @
    eval args[1] + '= obj'
    if args[2].includes(':')
      arr.push eval "(" + args[2] + ")"
    else
      arr.push eval args[2]
  arr
Array::reject = (func) ->
  arr=[]
  (arr.push(item) unless func(item)) for item in @
  arr
Array::remove = (arr) ->
  indices = []
  for item in arr
    indices.push(@indexOf(item)) if @indexOf(item) > -1
  (while indices.length > 0
    @splice(indices.drop(indices.max())[0],1)).flatten()
Array::select = (func) ->
  arr=[]
  (arr.push(item) if func(item)) for item in @
  arr
Array::sum = ->
  total = 0
  (total += parseFloat(i) if i) for i in @
  total
Array::update = (obj) ->
  return unless (obj || {}).hasOwnProperty('id')
  @[@index(obj)] = obj
Array::union = (arr) ->
  dup = @slice(0)
  dup.add(arr)
Array::unique = (filterOn) ->
  equiv = (first,second) ->
    return true if first == second
    return !first && !second
  newItems = []
  for item in @
    item = item[filterOn] if filterOn
    for newItem in newItems
      isDuplicate = false
      if equiv(item,newItem)
        isDuplicate = true
        break
    newItems.push(item) if (!isDuplicate)
  return newItems
Array::where = (obj) ->
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
