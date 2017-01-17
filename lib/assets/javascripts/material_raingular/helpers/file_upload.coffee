@Helpers ?= {}
class Helpers.FileUpload
  constructor: (@scope,@modelName,@key,@element,@callback)->
  uploadFile: (file)->
    @scope.progress = 0
    @element.addClass('covered')
    if id = @scope.$eval(@modelName).id
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
      if event.lengthComputable
        @scope.$apply =>
          @scope.progress = Math.round(event.loaded * 100 / event.total)
    , true
    xhr.addEventListener "readystatechange", (event) =>
      if event.target.readyState == 4 && !(event.target.status > 399)
        data = JSON.parse(event.target.response)
        @callback(data)
      else if event.target.readyState == 4 && event.target.status > 399
        @failed()
    , false
    xhr.addEventListener "error", @failed, false
    xhr.open(method, route)
    csrf = null
    for tag in document.getElementsByTagName('meta')
      csrf = tag.content if tag.name == 'csrf-token'
    xhr.setRequestHeader('X-CSRF-Token', csrf)
    xhr.send(formData)
  @failed: (event)=>
    @element.addClass('failed')

    timeout ->
      @element.removeClass('failed')
      @element.removeClass('covered')
    , 2000
