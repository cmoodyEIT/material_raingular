class MrDragModel extends AngularLinkModel
  initialize: ->
    @_element().draggable = true
    @_element().addEventListener 'dragstart', @_dragStart
    @_element().addEventListener 'dragend',   @_dragEnd
  _element: -> @$element[0]
  _dragStart: (event) =>
    @$scope.$event = event
    event.dataTransfer.setData('html',@_element())
    @$element.addClass('drag')
    @$scope.$eval(@$attrs.mrDrag)
  _dragEnd: (event) =>
    @$scope.$event = event
    @$element.removeClass('drag')
    @$scope.$eval(@$attrs.mrDragEnd) if @$attrs.mrDragEnd
  @register(Directives.MrDrag)
