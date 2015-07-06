class DateParser
  constructor: (object)->
    @object = object
  evaluate: ->
    return @object unless typeof @object == 'object' || typeof @object == 'array'
    if typeof @object == 'array'
      for obj in @object
        new DateParser(obj).evaluate
    if typeof @object == 'object'
      for key,value of @object
        if typeof value == 'string'
          @object[key] = new Date(value) if !!value.match(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/)
    return @object
angular.factories
  .factory 'DateConverterInterceptor', ($q, $rootScope) ->
    request: (config)          -> config
    requestError: (rejection)  -> rejection
    response: (response)       ->
      dp = new DateParser(response.data).evaluate()
      response
    responseError: (rejection) -> rejection
