angular.module('materialFilters', [])
  .filter 'trimLength', ->
    return (input, num, scope) ->
      return input unless typeof input == 'string'
      return input.substring(0,num || 20) + '...'
  .filter 'titleize', ->
    return (input) ->
      return unless input
      return input.replace(/\_/g,' ').replace(/\b[a-z]/g, (letter)->
        return letter[0].toUpperCase())
	.filter 'pluck', ->
    pluck = (objects, property) ->
      return [] if !(objects && property && angular.isArray(objects))
      property = String(property)
      return objects.map( (object) ->
        object = Object(object)
        return object[property] if (object.hasOwnProperty(property))
        return '')
    return (objects, property) ->
      return pluck(objects, property)
  .filter 'unique', ->
    return (items, filterOn) ->
      return items if filterOn == false
      if (filterOn || angular.isUndefined(filterOn)) && angular.isArray(items)
        newItems = []
        extractValueToCompare = (item) ->
          if angular.isObject(item) && angular.isString(filterOn) then item[filterOn] else item
      for item in items
        for newItem in newItems
          isDuplicate = false
          if (angular.equals(extractValueToCompare(newItem), extractValueToCompare(item)))
            isDuplicate = true
            break
        newItems.push(item) if (!isDuplicate)
      items = newItems
    return items;
  .filter 'join', ->
		return (list, token) ->
      return (list||[]).join(token)
