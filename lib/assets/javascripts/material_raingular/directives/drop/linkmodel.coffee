class MrDropModel extends AngularLinkModel
  initialize: ->
    @_element().droppable = true
    @_element().addEventListener 'drop',      @_drop
    @_element().addEventListener 'dragover',  @_dragOver
    @_element().addEventListener 'dragenter', @_dragEnter
    @_element().addEventListener 'dragleave', @_dragLeave

  _element: -> @$element[0]
  _drop: (event) =>
    @$scope.$event = event
    event.stopPropagation?()
    @$element.removeClass('over')
    @$scope.$eval(@$attrs.mrDrop)
  _dragOver: (event) =>
    @$scope.$event = event
    event.dataTransfer.dropEffect = 'move'
    event.preventDefault()
    @$element.addClass('over')
    @$scope.$eval(@$attrs.mrDragOver) if @$scope.$eval(@$attrs.mrDragOver)
  _dragEnter: (event) =>
    @$scope.$event = event
    event.preventDefault()
    @$element.addClass('over')
    @$scope.$eval(@$attrs.mrDragEnter) if @$scope.$eval(@$attrs.mrDragEnter)
  _dragLeave: (event) =>
    @$scope.$event = event
    @$element.removeClass('over')
    event.preventDefault()
    @$scope.$eval(@$attrs.mrDragLeave) if @$scope.$eval(@$attrs.mrDragLeave)
  @register(Directives.MrDrop)
