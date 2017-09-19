# //= require_tree ../../helpers
# //= require material_raingular/directives/upload/events
class DirectiveModels.MrUploadModel extends AngularLinkModel
  @inject(
    '$injector'
  )
  initialize: ->
    [@ngModelCtrl,@mrCallbackCtrl] = @$controller
    [@model,@key] = Helpers.NgModelParse(@$attrs.ngModel,@$scope)
    @fileUpload = new Helpers.FileUpload(@$scope,@model,@key,@$element,@callback.bind(@),@$injector)
    @options = @$scope.$eval(@$attrs.mrUploadOptions || '{}')
    new Modules.MrUploadEvents(@$element,@fileUpload,@disabled)
  callback: (data) ->
    @$scope[@model][@key] = data[@key]
    @$scope[@model].thumb = data.thumb
    @$scope[@model].id    = data.id unless @$scope[@model].id
    @$scope.progress = 100
    @$element.removeClass('covered')
    @mrCallbackCtrl?.evaluate(data)

  fileData: ->
    data = {}
    data.path  = @$scope[@model]?[@key]?.url
    data.name  = @$scope[@model]?[@key]?.name
    data.thumb = @$scope[@model]?.thumb?.url
    return data
  fileUploadShow: (type) -> @options[type]
  disabled: =>
    el = @$element[0]
    until !el.parentElement
      return true if el.getAttribute('disabled')
      el = el.parentElement
  accept: -> @$attrs.accept || '*'

  @register(Directives.MrUpload)
