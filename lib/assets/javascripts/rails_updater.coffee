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
    @scope[@modelName].$currentlyUpdating = [] unless @scope[@modelName].$currentlyUpdating
    atomName = if typeof @atomName == 'function' then @atomName(@scope) else @atomName
    @value = if @override then @scope.$eval(atomName) else value
    object = {id: @scope.$eval(@modelName).id}
    if object.id
      func = 'update'
      object[@railsName] = {}
    else
      object[@railsName] = @scope.$eval(@modelName)
      func = 'create'
    object[@railsName][atomName] = value
    unless @scope[@modelName].$currentlyUpdating.includes(atomName)
      @scope[@modelName].$currentlyUpdating.push(atomName)
      @factory[func] object, (returnData) =>
        @scope.$eval(@modelName).id = returnData.id if returnData.id
        @scope[@modelName].$currentlyUpdating.drop(atomName)
        unless @equiv(@ngModelCtrl.$viewValue,returnData[@atomName])
          @ngModelCtrl.$setModelValue = returnData[@atomName]
          @ngModelCtrl.$render()
        for controller in @controllers
          controller.evaluate(returnData) if !!controller
angular.module 'RailsUpdater',  ['Factories', 'FactoryName']
  .factory 'RailsUpdater', ($injector,factoryName,$parse) ->
    new: (scope,controllers,model,override,ngFactory)->
      return new RailsUpdate($injector,$parse,factoryName,scope,controllers,model,override,ngFactory)
