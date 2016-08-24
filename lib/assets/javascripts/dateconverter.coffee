# //= require dateparser
angular.factories
  .factory 'DateConverterInterceptor', ($q, $rootScope) ->
    request: (config)          -> config
    requestError: (rejection)  -> $q.reject(rejection)
    response: (response)       ->
      new DateParser(response.data).evaluate()
      response
    responseError: (rejection) -> $q.reject(rejection)
