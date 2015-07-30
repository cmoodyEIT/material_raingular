# //= require dateparser
angular.factories
  .factory 'DateConverterInterceptor', ($q, $rootScope) ->
    request: (config)          -> config
    requestError: (rejection)  -> rejection
    response: (response)       ->
      new DateParser(response.data).evaluate()
      response
    responseError: (rejection) -> rejection
