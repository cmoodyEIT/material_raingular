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
  setPosition: (target,$mdPanel,options) ->
    options ||= {}
    @position = $mdPanel.newPanelPosition().relativeTo(target).addPanelPosition($mdPanel.xPosition[options.x || 'ALIGN_START'], $mdPanel.yPosition[options.y || 'BELOW'])
    return @
  setAnimation: (type,$mdPanel,options) ->
    options ||= {}
    @animation ||= $mdPanel.newPanelAnimation()
    @animation.openFrom(options.openFrom || @target)
    @animation.closeTo(@target)
    @animation.withAnimation($mdPanel.animation[type])
    return @
