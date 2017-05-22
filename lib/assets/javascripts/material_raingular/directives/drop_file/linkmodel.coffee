# //= require material_raingular/directives/drop_file/drop_events
class DirectiveModels.MrDropFileModel extends AngularLinkModel
  @inject('$injector')
  initialize: ->
    [@ngModelCtrl,@mrCallbackCtrl] = @$controller
    [@model,@key] = Helpers.NgModelParse(@$attrs.ngModel,@$scope)
    @fileUpload = new Helpers.FileUpload(@$scope,@model,@key,@$element,@callback,@$injector)
    new Modules.MrDropFileEvents(@$element,@fileUpload)

  callback: (data) =>
    @$scope.$apply =>
      @$scope[@model][@key] = data[@key]
      @$scope[@model].thumb = data.thumb
      @$scope[@model].id    = data.id unless @$scope[@model].id
      @$scope.progress = 100
      @$element.removeClass('covered')
      @mrCallbackCtrl?.evaluate(data)
  @register(Directives.MrDropFile)
