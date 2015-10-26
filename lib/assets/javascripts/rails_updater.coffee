class RailsUpdate
  constructor: ($injector,$parse,factoryName,scope,controllers,model,override)->
    @injector    = $injector
    @factoryName = factoryName
    @scope       = scope
    modelName    = (override || model)
    if parts = modelName.match(/(.+)\[(.+)\]/)
      @modelName = parts[1]
      @atomName  = $parse(parts[2])
    else
      [@modelName,@atomName] = modelName.split('.')
    @override    = !!override
    @factory     = @injector.get(@factoryName(@modelName))
    @controllers = controllers.slice(0)
    @ngModelCtrl = @controllers.shift()
    return @
  equiv: (left,right) ->
    return true if left == right
    return true if (!!left && !!right) == false
    false
  update: (value) ->
    atomName = if typeof @atomName == 'function' then @atomName(@scope) else @atomName
    @value = if @override then scope.$eval(atomName) else value
    object = {id: @scope.$eval(@modelName).id}
    object[@modelName] = {}
    object[@modelName][atomName] = value
    unless @scope[@modelName].currently_updating
      @scope[@modelName].currently_updating = true
      up = @
      @factory.update object, (returnData) ->
        up.scope[up.modelName].currently_updating = false
        unless up.equiv(up.ngModelCtrl.$viewValue,returnData[up.atomName])
          up.ngModelCtrl.$setModelValue = returnData[up.atomName]
          up.ngModelCtrl.$render()
        for controller in up.controllers
          controller.evaluate(returnData) if !!controller
angular.module 'RailsUpdater',  ['Factories', 'FactoryName']
  .factory 'RailsUpdater', ($injector,factoryName,$parse) ->
    new: (scope,controllers,model,override)->
      return new RailsUpdate($injector,$parse,factoryName,scope,controllers,model,override)
