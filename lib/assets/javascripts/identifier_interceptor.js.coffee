angular.factories
  .factory 'IdentifierInterceptor', ($q, $rootScope) ->
    request: (config)          ->
      config.headers.angular = true
      config
    requestError: (rejection)  -> rejection
    response: (response)       -> response
    responseError: (rejection) -> rejection
