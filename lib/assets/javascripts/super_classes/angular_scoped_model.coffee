# //= require ./angular_model
class @AngularScopedModel extends AngularModel
  @inject: (args...) ->
    args.push('$scope','$rootScope','$routeParams','$controller')
    @$inject = args
  @extendController:  ->
    @$extendedControllers = [].slice.call(arguments,0)
  constructor: (args...) ->
    # Bind injected dependencies on scope ie @$scope
    for key, index in @constructor.$inject || []
      @[key] = args[index]
    # extend controllers
    for controller in @constructor.$extendedControllers || []
      name = controller.name || controller
      opts = {$scope: @$scope}
      opts[key] = @[val] for key,val of controller.scope || {}
      angular.extend @, @$controller name, opts
    # Bind all functions not begining with _ to scope
    for key, val of @constructor.prototype
      continue if key in ['constructor', 'initialize'] or key[0] is '_'
      @$scope[key] = if (typeof val is 'function') then val.bind?(@) || _.bind(val, @) else val

    # Run initialize function if exists
    @initialize?()
