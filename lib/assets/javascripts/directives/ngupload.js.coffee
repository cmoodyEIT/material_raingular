class FileUpload
  constructor: (@parse,@scope,controllers,model,override,@element)->
    [@ngModel,@ngCallback] = controllers
    modelName    = (override || model)
    if parts = modelName.match(/(.+)\[(.+)\]/)
      @modelName = parts[1]
      @atomName  = @parse(parts[2])()
    else
      [@modelName,@atomName] = modelName.split('.')
    @override    = !!override
  uploadFile: (file)->
    @scope.progress = 0
    @element.addClass('covered')
    id = @scope.$eval(@modelName).id
    route = Routes[@modelName + '_path'](id: id) + '.json'
    formData = new FormData()
    formData.append @modelName + '[id]', id
    formData.append @modelName + '[' + @atomName + ']', file
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener "progress", (event) =>
      if event.lengthComputable
        @scope.$apply =>
          @scope.progress = Math.round(event.loaded * 100 / event.total)
    , true
    xhr.addEventListener "readystatechange", (event) =>
      if event.target.readyState == 4 && !(event.target.status > 399)
        data = JSON.parse(event.target.response)
        @scope.$apply =>
          @scope[@modelName][@atomName] = data[@atomName]
          @scope[@modelName].thumb = data.thumb
          @scope.progress = 100
          @element.removeClass('covered')
          @ngCallback.evaluate(data) if !!@ngCallback
      else if event.target.readyState == 4 && event.target.status > 399
        failed()
    , false
    xhr.addEventListener "error", (event) ->
      failed()
    , false
    failed = ->
      @element.addClass('failed')

      timeout ->
        @element.removeClass('failed')
        @element.removeClass('covered')
      , 2000

    xhr.open("PUT", route)
    csrf = null
    for tag in document.getElementsByTagName('meta')
      csrf = tag.content if tag.name == 'csrf-token'
    xhr.setRequestHeader('X-CSRF-Token', csrf)
    xhr.send(formData)

  fileData: ->
    data = {}
    if @scope[@modelName]
      if @scope[@modelName][@atomName]
        data.path  = @scope[@modelName][@atomName].url
        data.name  = @scope[@modelName][@atomName].name
        data.thumb = @scope[@modelName].thumb.url if @scope[@modelName].thumb
    return data

class NgUploadEvents
  constructor: (@element,@file_upload,@disabled) ->
    @element.children().bind 'click', (event) =>
      return if @disabled()
      return if event.target.tagName == 'A'
      event.target.parentElement.getElementsByTagName('input')[0].click()
    @element.children('input').bind 'change', (event) =>
      return if @disabled()
      file   = event.target.files[0]
      @file_upload.uploadFile(file)

class NgDropFileEvents
  constructor: (@element,@file_upload) ->
    dragHovered = 0
    el = angular.element("<div class='hovered-cover'>Drop Files Here</div>")
    @element.bind 'dragenter', (event) =>
      dragHovered += 1
      @element.addClass('hovered') if dragHovered == 1
      @element.append el if dragHovered == 1
      height = window.getComputedStyle(@element[0]).height
      el.css('height', height)
      el.css('line-height',height)
      el.css('margin-top', '-' + height)
    @element.bind 'dragleave', (event) =>
      dragHovered -= 1
      @element.removeClass('hovered') if dragHovered == 0
      el.remove() if dragHovered == 0
    @element.bind 'dragover', (event) =>
      event.preventDefault()
      event.stopPropagation()
    @element.bind 'drop', (event) =>
      event.preventDefault()
      event.stopPropagation()
      @element.removeClass('hovered')
      el.remove()
      dragHovered = 0
      file   = (event.originalEvent || event).dataTransfer.files[0]
      @file_upload.uploadFile(file)

angular.module('NgUpload', [])

  .directive 'ngDropFile', ($timeout,$parse) ->
    restrict: 'A'
    require: ['ngModel','?ngCallback']
    link: (scope, element, attributes,controllers) ->
      file_upload = new FileUpload($parse,scope,controllers,attributes.ngModel,attributes.ngOverride,element)
      new NgDropFileEvents(element,file_upload)
      scope.file_upload_data =        -> file_upload.fileData()

  .directive 'ngUpload', ($timeout, $parse) ->
    restrict: 'E'
    replace: true,
    require: ['ngModel','?ngCallback'],
    template: (element,attributes) ->
      disabled = typeof(attributes.disabled) != 'undefined'
      '<span class="ng-upload" style="outline: none">
        <div class="ng-progress-bar">
          <span class="bar" style="width: {{progress || 0}}%;"></span><span class="text" style="margin-left: -{{uploadProgress() || 0}}%;">{{uploadProgress()}}%</span>
        </div>
        <input accept="{{accept()}}" ng-model="ngModel" type="file" ng-class="{image: file_upload_show(&#39;image&#39;)}" ' + (if disabled then 'disabled ') + '/><img ng-show="file_upload_show(&#39;image&#39;)" ng-src="{{file_upload_data().thumb}}" />
        <div class="button" ng-show="file_upload_show(&#39;button&#39;)">
          Select File
        </div>
        <a download="" href="{{file_upload_data().path}}" ng-show="file_upload_show(&#39;text&#39;)" target="_blank">{{file_upload_data().name}}</a></span>'

    link: (scope, element, attributes,controllers) ->
      file_upload = new FileUpload($parse,scope,controllers,attributes.ngModel,attributes.ngOverride,element)
      options = $parse(attributes.ngUploadOptions)()
      scope.file_upload_show = (type) -> options[type]
      scope.file_upload_data =        -> file_upload.fileData()
      scope.accept           =        -> attributes.accept || '*'
      disabled = ->
        el = element[0]
        until !el.parentElement
          return true if el.getAttribute('disabled')
          el = el.parentElement
      new NgUploadEvents(element,file_upload,disabled)
