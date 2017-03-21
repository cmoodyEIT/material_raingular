REGEXP = /^\s*([\s\S]+?)(?:\s+as\s+([\s\S]+?))?(?:\s+group\s+by\s+([\s\S]+?))?(?:\s+disable\s+when\s+([\s\S]+?))?\s+for\s+(?:([\$\w][\$\w]*)|(?:\(\s*([\$\w][\$\w]*)\s*,\s*([\$\w][\$\w]*)\s*\)))\s+in\s+([\s\S]+?)(?:\s+track\s+by\s+([\s\S]+?))?$/;
    # 1: Model Value
    # 2: Display Value
    # 3: group by expression (groupByFn)
    # 4: disable when expression (disableWhenFn)
    # 5: Repeater
    # 6: object item key variable name
    # 7: object item value variable name
    # 8: collection
    # 9: track by expression
class MrMobileSelectModel extends AngularLinkModel
  @inject('$parse')
  initialize: ->
    @filters      = @$attrs.mrOptions.split('|')
    @options      = @filters.shift()
    @match        = @options.match(REGEXP)
    @raiseError() if !@match
    @repeater     = @match[5]
    @collection   = @$parse(@match[8])
    @modelValue   = @match[1].replace(@match[5] + '.','')
    @viewValue    = if @match[2] then @match[2].replace(@match[5] + '.','') else @modelValue
    @modelValueFn = if @modelValue == @match[5] then @PrimitiveValueFunction else @$parse(@modelValue || @viewValue)
    @viewValueFn  = if @viewValue  == @match[5] then @PrimitiveValueFunction else @$parse(@viewValue || @modelValue)
    @isPrimative  =    @viewValue  == @match[5]
    @$scope.$watch @$modelValue.bind(@), (newVal) =>
      @$element.html('')
      @$element.html(newVal || @$attrs.placeholder)

  PrimitiveValueFunction: (s,l,a,i) -> return s
  $modelValue: -> @$controller.$modelValue

  raiseError: ->
    throw new Error(
      "Expected expression in form of " +
      "'_select_ (as _label_)? for (_key_,)?_value_ in _collection_'" +
      " but got '" + @$attrs.mrOptions + "'. Element: " + @html)
  @register(Directives.MrMobileSelect)
