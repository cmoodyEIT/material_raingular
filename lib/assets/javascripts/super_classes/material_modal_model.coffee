# //= require ./angular_scoped_model
@ModalModels ||= {}
class @MaterialModalModel extends AngularScopedModel
  @locals: (args...) ->
    @$inject ||= []
    @$inject.merge(args)
    @$locals = args
  @inject: (args...) ->
    args.push('$scope','$rootScope','$mdDialog')
    @$inject ||= []
    @$inject.merge(args)
  constructor: (args...) ->
    # Bind injected dependencies on scope ie @$scope
    for key, index in @constructor.$inject || []
      @[key] = args[index]
    for key in @constructor.$locals || []
      @$scope[key] = @[key]
    @$scope.hide = @$scope.cancel = @$scope.close = @$mdDialog.hide

    # Bind all functions not begining with _ to scope
    for key, val of @constructor.prototype
      continue if key in ['constructor', 'initialize'] or key[0] is '_'
      @$scope[key] = if (typeof val is 'function') then val.bind?(@) || _.bind(val, @) else val

    # Run initialize function if exists
    @initialize?()
