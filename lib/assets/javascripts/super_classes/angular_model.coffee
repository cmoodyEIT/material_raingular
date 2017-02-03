# //= require ./module
class @AngularModel extends Module
  # Automatically registers the controller to the module
  @register: (app, name,type) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    app?[type] name, @
  #  Injects dependencies included in args
  @inject: (args...) ->
    @$inject ||= []
    @$inject.merge args

  constructor: (args...) ->
    # Bind injected dependencies on scope ie @$scope
    for key, index in @constructor.$inject || []
      @[key] = args[index]

    # Run initialize function if exists
    @initialize?()
