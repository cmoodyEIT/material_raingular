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
  time__cards: -> #'/time_cards'
    return {}
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
      obj = val()
      obj.template ||= '' unless obj.templateUrl
      unless key in ['default','otherwise']
        route = key.replace(/\_/g,'/:').underscore().replace(/\_/g,'/').replace(/\/\:\/\:/g,'_')
        route = '/' + route unless route[0] is '/'
        $routeProvider.when(route,obj)
      else if key == 'default'
        $routeProvider.when('/',obj)
      else
        $routeProvider.otherwise(obj)
    return $routeProvider
