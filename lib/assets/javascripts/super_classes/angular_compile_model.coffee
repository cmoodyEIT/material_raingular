# //= require super_classes/angular_model
class @AngularCompileModel extends AngularModel
  @register: (model,type) -> model::[type || 'compile'] = (args...) => new @(args...)
  @$default_arguments: ['element','attrs','transcludeFn']
  constructor: (args...) ->
    for key,index in @constructor.$default_arguments
      @['$' + key] = args[index]
    @$injector = angular.element(document.body).injector()
    for key in @constructor.$inject || []
      @[key] = @$injector.get(key)
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
