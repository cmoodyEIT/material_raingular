@Helpers ?= {}
class Helpers.FileUpload
  constructor: (@scope,@modelName,@key,@element,@callback,@$injector)->
    @$timeout = @$injector.get '$timeout'
    @$q       = @$injector.get '$q'
    @model = @scope.$eval(@modelName)
    ActiveRecord.$Resource._resourcify(@model,@modelName.classify())
  uploadFile: (file)->
    @scope.progress = 0
    @element.addClass('covered')
    if id = @model.id
      route = Routes[@modelName + '_path'](id: id) + '.json'
      method = 'PUT'
    else
      route = Routes[@modelName.pluralize() + '_path']() + '.json'
      method = 'POST'
    formData = new FormData()
    formData.append @modelName + '[id]', id if id
    formData.append @modelName + '[' + @key + ']', file
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener "progress", (event) =>
      return unless event.lengthComputable
      @scope.$apply =>
        @scope.progress = Math.round(event.loaded * 100 / event.total)
    , true
    xhr.addEventListener "error", @failed.bind(@), false
    xhr.open(method, route)
    csrf = null
    for tag in document.getElementsByTagName('meta')
      csrf = tag.content if tag.name == 'csrf-token'
    xhr.setRequestHeader('X-CSRF-Token', csrf)
    promise = ->
      @$q (resolve,reject) ->
        xhr.onreadystatechange = ->
          return unless xhr.readyState == 4
          if xhr.status == 200
            resolve(JSON.parse xhr.responseText)
          else
            reject(JSON.parse xhr.responseText)
        xhr.send(formData)
    # @model.$promise.then promise
    # if (@$promise.$$state.status != 0 || !@$resolved)
    # promise
    @model.$promise = @model.$promise.then(promise.bind(@)).then(@success.bind(@),@failed.bind(@))
    # @model.$promise.then @success.bind(@),@failed.bind(@)
  success: (data) ->
    console.dir data
    @callback(data)
  failed: (data) ->
    @element.addClass('failed')

    @$injector.get('$timeout') =>
      @element.removeClass('failed')
      @element.removeClass('covered')
    , 2000
