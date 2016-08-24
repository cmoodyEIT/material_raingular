angular.factories
  .factory 'IdentifierInterceptor', ($q, $rootScope) ->
    request: (config)          ->
      config.headers.angular = true
      config
    requestError: (rejection)  -> $q.reject(rejection)
    response: (response)       -> response
    responseError: (rejection) -> $q.reject(rejection)
