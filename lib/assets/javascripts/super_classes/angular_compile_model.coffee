# //= require super_classes/angular_scoped_model
class @AngularCompileModel extends AngularModel
  @register: (model,type) -> model::[type || 'compile'] = (args...) => new @(args...)
  @$default_arguments: ['element','attrs','transcludeFn']
  constructor: (args...) ->
    @$injector = angular.element(document.body).injector()
    for key in @constructor.$inject || []
      @[key] = @$injector.get(key)
    for key,index in @constructor.$default_arguments
      @['$' + key] = args[index]
    # Bind all functions not begining with _ to scope
    for key, val of @constructor.prototype
      continue if key in ['constructor', 'initialize'] or key[0] is '_'
      @$scope[key] = if (typeof val is 'function') then val.bind?(@) || _.bind(val, @) else val

    @initialize?()
###
class CompileModel extends AngularLinkModel
  @inject('Project')
  initialize: ->
    console.dir 'howdy'
    console.dir @$scope
    console.dir @Project
  @register(testDirective)      #NOTE: Must be called last in directive since it instantiates a new model instance
###                             #NOTE: argument should be directive model
