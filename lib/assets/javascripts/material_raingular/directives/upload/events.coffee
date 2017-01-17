class Modules.MrUploadEvents
  constructor: (@element,@fileUpload,@disabled) ->
    @element.children().bind 'click', (event) =>
      return if @disabled()
      return if event.target.tagName == 'A'
      event.target.parentElement.getElementsByTagName('input')[0].click()
    @element.children('input').bind 'change', (event) =>
      return if @disabled()
      file   = event.target.files[0]
      @fileUpload.uploadFile(file)
