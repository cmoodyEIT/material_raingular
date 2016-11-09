class @PanelConfig
  constructor: (config) ->
    for key,value of config || {}
      @[key] = value
    @attachTo            ||= angular.element(document.body)
    @clickOutsideToClose ||= true
    @escapeToClose       ||= true
    @focusOnOpen         ||= false
    @zIndex              ||= 2
    @openFrom            ||= @event
    @target              ||= @event.target
    @panelClass          ||= 'md-select-menu'
  setPosition: (target,$mdPanel) ->
    @position = $mdPanel.newPanelPosition().relativeTo(target).addPanelPosition($mdPanel.xPosition.ALIGN_START, $mdPanel.yPosition.BELOW)
    return @
