# //= require super_classes/angular_compile_model
class @AngularLinkModel extends AngularCompileModel
  @register: (model) -> super(model,'link')
  @$default_arguments: ['scope','element','attrs','controller','transcludeFn'] #NOTE: Order matters

###
class LinkModel extends AngularLinkModel
  @inject('Project')
  initialize: ->
    console.dir 'howdy'
    console.dir @$scope
    console.dir @Project
  @register(testDirective)      #NOTE: Must be called last in directive since it instantiates a new model instance
###                             #NOTE: argument should be directive model
