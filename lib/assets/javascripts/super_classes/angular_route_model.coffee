# //= require super_classes/angular_model
###
class @AdminRouteModel extends AngularRouteModel
  default: ->    #'/'
    controller: 'Admin'
  _id: ->        #'/:id'
    controller: 'Admin'
  person_id: ->  #'/person/:id'
    controller: 'Admin'
  personName: -> #'/person/name'
    controller: 'Admin'
  otherwise: ->
    redirectTo: '/'
  @register(angular.app)
###
class @AngularRouteModel extends AngularModel
  @register: (app) ->
    app.config(($routeProvider,$locationProvider) => new @($routeProvider,$locationProvider))
  constructor: ($routeProvider,$locationProvider)->
    for key, val of @constructor.prototype
      continue if key in ['constructor', 'initialize']
      unless key in ['default','otherwise']
        route = key.replace('_','/:').tableize().singularize().replace('_','/')
        route = '/' + route unless route[0] is '/'
        $routeProvider.when(route,val())
      else if key == 'default'
        $routeProvider.when('/',val())
      else
        $routeProvider.otherwise(val())
    return $routeProvider
