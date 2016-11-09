# //= require super_classes/angular_view_model
@DirectiveModels ||= {}
class @AngularDirectiveModel extends @AngularViewModel
  @register: -> console.warn "Directive models can not be registered. Perhaps you were trying to use a view model?"

###
class TestDirectiveModel extends AngularDirectiveModel
  @register(angular.app)  #NOTE: Raises Warning.  Do not register
  @inject('Person')       #NOTE: Inject Dependencies
  initialize: ->          #NOTE: Runs on initialization
    console.dir @Person
    console.dir 'controller'
###
