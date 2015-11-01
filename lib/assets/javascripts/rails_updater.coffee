class RailsUpdate
  constructor: ($injector,$parse,factoryName,scope,controllers,model,override,ngFactory)->
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
    @factory     = @injector.get(@factoryName(ngFactory || @modelName))
    @controllers = controllers.slice(0)
    @ngModelCtrl = @controllers.shift()
    @railsName   = ngFactory || @modelName
    return @
  equiv: (left,right) ->
    return true if left == right
    return true if (!!left && !!right) == false
    false
  update: (value) ->
    atomName = if typeof @atomName == 'function' then @atomName(@scope) else @atomName
    @value = if @override then @scope.$eval(atomName) else value
    object = {id: @scope.$eval(@modelName).id}
    object[@railsName] = {}
    object[@railsName][atomName] = value
    unless @scope[@modelName].currently_updating
      @scope[@modelName].currently_updating = true
      @factory.update object, (returnData) =>
        @scope[@modelName].currently_updating = false
        unless @equiv(@ngModelCtrl.$viewValue,returnData[@atomName])
          @ngModelCtrl.$setModelValue = returnData[@atomName]
          @ngModelCtrl.$render()
        for controller in @controllers
          controller.evaluate(returnData) if !!controller
angular.module 'RailsUpdater',  ['Factories', 'FactoryName']
  .factory 'RailsUpdater', ($injector,factoryName,$parse) ->
    new: (scope,controllers,model,override,ngFactory)->
      return new RailsUpdate($injector,$parse,factoryName,scope,controllers,model,override,ngFactory)
