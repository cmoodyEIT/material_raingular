class @AngularInjectableModel
  $inject: (args...) ->
    @$injector ||= angular.element(document.body).injector()
    for item in args
      @[item] = @$injector.get(item)
