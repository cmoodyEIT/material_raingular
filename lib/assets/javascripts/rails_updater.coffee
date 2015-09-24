class RailsUpdate
  constructor: ($injector,factoryName,scope,controllers,model,override)->
    @injector    = $injector
    @factoryName = factoryName
    @scope       = scope
    @modelName   = (override || model).split('.')[0]
    @atomName    = (override || model).split('.')[1]
    @override    = !!override
    @factory     = @injector.get(@factoryName(@modelName))
    @object      = {id: scope[@modelName].id}
    @ngModelCtrl = controllers.shift()
    @controllers = controllers
    return @
  equiv: (left,right) ->
    return true if left == right
    return true if (!!left && !!right) == false
    false
  update: (value) ->
    @value       = if @override then scope.$eval(@atomName) else value
    @object[@atomName] = value
    unless @scope[@modelName].currently_updating
      @scope[@modelName].currently_updating = true
      up = @
      @factory.update @object, (returnData) ->
        up.scope[up.modelName].currently_updating = false
        unless up.equiv(up.ngModelCtrl.$viewValue,returnData[up.atomName])
          up.ngModelCtrl.$setModelValue = returnData[up.atomName]
          up.ngModelCtrl.$render()
        for controller in up.controllers
          controller.evaluate(returnData) if !!controller
angular.module 'RailsUpdater',  ['Factories', 'FactoryName']
  .factory 'RailsUpdater', ($injector,factoryName) ->
    new: (scope,controllers,model,override)->
      return new RailsUpdate($injector,factoryName,scope,controllers,model,override)
