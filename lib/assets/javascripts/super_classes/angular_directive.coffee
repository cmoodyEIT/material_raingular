#//= require super_classes/angular_model

### Example Usage
class testDirective extends AngularDirectiveModel
  @inject('Project')              #NOTE: Inject any dependencies
  initialize: ->                  #NOTE: This method is called immediately upon creation of the directive
    console.dir @Project          #NOTE: The Project factory has been injected and is available on this
  restrict: 'E'                   #NOTE: Declare typical angular directive statements
  replace: true
  template: '<div> Hello</div>'
  controller: DirectiveModel      #NOTE: Use a class defined extending AngularDirectiveModel
  link: LinkModel                 #NOTE: Can't be set here if using AngularLinkModel
  compile: CompileModel           #NOTE: Same as above, if set link is unset


  # Other Options
    priority: 0,
    template: '<div></div>', or function(tElement, tAttrs) { ... },
    or
    templateUrl: 'directive.html', or function(tElement, tAttrs) { ... },
    transclude: false,
    templateNamespace: 'html',
    scope: false,
    controllerAs: 'stringIdentifier',
    bindToController: false,
    require: 'siblingDirectiveName', or ['^parentDirectiveName', '?optionalDirectiveName', '?^optionalParent'],
    multiElement: false,

  @register(angular.app)          #NOTE: Must be called last in directive since it instantiates a new model instance
###
@Directives ||= {}
class @AngularDirective extends AngularModel
  # Automatically registers the controller to the module
  @register: (app, name,type) ->
    name ?= (@name || @toString().match(/function\s*(.*?)\(/)?[1]).tableize().camelize('lower').singularize()
    app?[type || 'directive'] name, ['$injector', ($injector) => new @($injector)]
  constructor: ($injector) ->
    # Bind injected dependencies on scope ie @$scope
    for key in @constructor.$inject || []
      @[key] = $injector.get(key)
    # Run initialize function if exists
    @initialize?()
