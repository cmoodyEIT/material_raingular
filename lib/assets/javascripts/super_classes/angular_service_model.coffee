# //= require ./angular_model
@ServiceModels ||= {}
class @AngularServiceModel extends AngularModel
  # Automatically registers the service to the module
  @register: (app, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    app?.service name, @
