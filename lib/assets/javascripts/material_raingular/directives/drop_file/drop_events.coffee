class Modules.MrDropFileEvents
  constructor: (@element,@fileUpload) ->
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
      @fileUpload.uploadFile(file)
