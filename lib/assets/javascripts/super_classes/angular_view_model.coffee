# //= require ./angular_scoped_model
@ViewModels ||= {}
class @AngularViewModel extends AngularScopedModel
  # Automatically registers the controller to the module
  @register: (app, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    app.controller? name, @
