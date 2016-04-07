class SelectOptions
  REGEXP: /^\s*([\s\S]+?)(?:\s+as\s+([\s\S]+?))?(?:\s+group\s+by\s+([\s\S]+?))?(?:\s+disable\s+when\s+([\s\S]+?))?\s+for\s+(?:([\$\w][\$\w]*)|(?:\(\s*([\$\w][\$\w]*)\s*,\s*([\$\w][\$\w]*)\s*\)))\s+in\s+([\s\S]+?)(?:\s+track\s+by\s+([\s\S]+?))?$/;
      # 1: Model Value
      # 2: Display Value
      # 3: group by expression (groupByFn)
      # 4: disable when expression (disableWhenFn)
      # 5: Repeater
      # 6: object item key variable name
      # 7: object item value variable name
      # 8: collection
      # 9: track by expressionj
  constructor: (@unparsed,@html) ->
    @filters  = @unparsed.split('|')
    @options  = @filters.shift()
    @match    = @options.match(@REGEXP)
    @raiseError() if !@match
  raiseError: ->
    throw new Error(
      "Expected expression in form of " +
      "'_select_ (as _label_)? for (_key_,)?_value_ in _collection_'" +
      " but got '" + @unparsed + "'. Element: " + @html)
PrimitiveValueFunction = (s,l,a,i) ->
  return s

class SelectFunctions
  constructor: (match,parse) ->
    @collection   = parse(match[8])
    @modelValue   = match[1].replace(match[5] + '.','')
    @viewValue    = if match[2] then match[2].replace(match[5] + '.','') else @modelValue
    @modelValueFn = if @modelValue == match[5] then PrimitiveValueFunction else parse(@modelValue || @viewValue)
    @viewValueFn  = if @viewValue  == match[5] then PrimitiveValueFunction else parse(@viewValue || @modelValue)
    @isPrimative  =    @viewValue  == match[5]

class MobileTemplate
  constructor: (@element,functions) ->
    @template          = angular.element("<ul> </ul>")
    @search            = angular.element "<input type='search' placeholder='Search'>"
    @tempHolder        = angular.element("<div class='filtered-select' ></div>")
    @body              = angular.element(document.body)
    @mousedownFunction = functions[0]
    @keydownFunction   = functions[1]
    @inputFunction     = functions[2]

    @bind()
    @stylize()
    @attachElements()
  attachElements: ->
    @tempHolder.append @search
    @tempHolder.append @template
    @body.append @tempHolder
  stylize: ->
    ulHeight = =>
      full = window.innerHeight
      full = full/2 if @element.hasClass('bottom')
      full - @search[0].offsetHeight + 'px'
    @tempHolder.addClass('bottom') if @element.hasClass('bottom')
    @template.css('height',ulHeight())

  bind: ->
    @element.bind 'mousedown', (event) =>
      @mousedownFunction(@tempHolder,@search,event)
    @body.bind 'keydown', (event) =>
      @keydownFunction(@tempHolder,event)
    @search.bind 'input', (event) =>
      @inputFunction(event)

class StandardTemplate
  constructor: (@element,attrs,functions,@disabled) ->
    @span            = angular.element "<span></span>"
    @search          = angular.element "<input class='autocomplete' type='search' placeholder='" + attrs.placeholder + "'>"
    @tempHolder      = angular.element "<div class='autocomplete menu md-whiteframe-z1'>"
    @template        = @tempHolder
    @typeAhead       = angular.element "<span style='position:absolute;'></span>"
    @inputFunction   = functions[0]
    @focusFunction   = functions[1]
    @blurFunction    = functions[2]
    @keydownFunction = functions[3]
    @attachElements()
    @stylize()
    @bind()
  stylize: ->
    @search.css('width',window.getComputedStyle(@element[0]).width)
    @search.addClass('md-input') if @element.hasClass('md-input')
    @search.css('color', 'black')
    @element.css('position','relative').css('overflow','visible')
    @span.css('overflow','hidden').css('width','100%').css('display','inline-block').css('position','relative')
    searchCss = window.getComputedStyle(@search[0])
    @typeAhead.css('white-space', 'nowrap')
    @typeAhead.css('padding-left', parseFloat(searchCss["padding-left"]) + parseFloat(searchCss["margin-left"]) + parseFloat(searchCss["border-left-width"]) + 'px')
    padding  = parseFloat(searchCss["padding-top"])  + parseFloat(searchCss["margin-top"])  + parseFloat(searchCss["border-top-width"])
    parent = @element[0]
    until parent.tagName == 'TD'
      break unless parent.parentNode
      parent = parent.parentNode
    padding += 1 unless parent.tagName == 'TD'
    @typeAhead.css('padding-top',  padding + 'px')

  bind: ->
    @search.bind 'input', (event)=>
      @inputFunction(@search,@typeAhead,event)
    @search.bind 'focus', (event)=>
      @stylize()
      @focusFunction(@template,event)
    @search.bind 'blur', (event)=>
      @blurFunction(@search,@typeAhead,@template,event)
    @search.bind 'keydown', (event)=>
      @keydownFunction(@search,@typeAhead,@template,event)
  attachElements: ->
    @span.append @typeAhead
    @span.append @search
    @element.append @span
    @element.append @tempHolder

class EventFunctions
  constructor: (@functions,@buildTemplate,@updateValue,@filteredList,@filter,@timeout,@parse,@scope,@disabled,@options) ->

  inputFunction: (search,typeAhead,event) =>
    location = search[0].selectionStart
    if location > 3
      if @functions.viewValueFn(@filteredList()[0])
        search.val(@functions.viewValueFn(@filteredList()[0]).replace(/^\s+/g,''))
      else
        search.val(search.val()[0..location - 1].replace(/^\s+/g,''))
      search[0].setSelectionRange(location,location)
    else
      search.val(search.val()[0..2].replace(/^\s+/g,''))
    typeAhead.html(search.val()[0..location - 1])
    @buildTemplate()

  focusFunction: (template,event) =>
    template.addClass('focused')

    @buildTemplate()
  setTypeAheadScroll: (search,typeAhead) =>
    if search[0].offsetWidth < search[0].scrollWidth
      @timeout ->
        typeAhead.css('margin-left', '-' + search[0].scrollLeft + 'px')
      , 1
  blurFunction: (search,typeAhead,template,event) =>
    template.removeClass('focused')
    @setTypeAheadScroll(search,typeAhead)
    if search.val().length < (@options.minLength || 4)
      search.val('')
    else
      obj={}
      obj[@functions.viewValue] = search.val()
      val = @filter('filter')(@functions.collection(@scope), obj)[0]
      @updateValue @functions.modelValueFn(val)
      search.val(@functions.viewValueFn(val).replace(/^\s+/g,''))

  keydownFunction: (search,typeAhead,template,input) =>
    @setTypeAheadScroll(search,typeAhead)
    keypress = (direction) ->
      index = if direction == 'next' then 0 else template.find('a').length - 1
      selected = angular.element(template[0].getElementsByClassName('active')[0])
      if selected.hasClass('active')
        selected.removeClass('active')
        until complete
          selected = angular.element(selected[0][direction + 'Sibling']) if selected[0]
          complete = !!selected[0]
          complete = selected[0].tagName == 'A' if complete
          complete = true if !selected[0]
      selected = angular.element(template.find('a')[index]) unless selected[0]
      ind = 0
      for el,i in template[0].getElementsByTagName('a')
        ind = i if el == selected[0]
      scroll = selected[0].scrollHeight * ind
      selected[0].parentElement.scrollTop = scroll
      selected.addClass('active')
      location = search[0].selectionStart
      search.val(selected.text().replace(/^\s+/g,''))
      search[0].setSelectionRange(location,location)
      typeAhead.html(selected.text()[0..location - 1])
    if input.keyCode == 40
      input.preventDefault()
      keypress('next')
    if input.keyCode == 38
      input.preventDefault()
      keypress('previous')
  mkeydownFunction: (tempHolder,event) =>
    tempHolder.removeClass('active') if event.keyCode == 27
  mousedownFunction: (tempHolder,search,event) =>
    return if tempHolder.hasClass('active')
    return if @disabled()
    search.val('')
    @buildTemplate()
    tempHolder.css('top',event.clientY)
    tempHolder.css('transition','none')
    @timeout ->
      tempHolder.css('transition','')
      tempHolder.css('top','')
      tempHolder.addClass('active')
  minputFunction: (event) =>
    @buildTemplate()

  standard: ->
    [@inputFunction,@focusFunction,@blurFunction,@keydownFunction]
  mobile: ->
    [@mousedownFunction,@mkeydownFunction,@minputFunction]


angular.module('FilteredSelect', [])
  .directive 'ngFilteredSelect', ($parse,$filter,$timeout)->
    require: 'ngModel'
    link: (scope,element,attrs,ngModel) ->
      equiv = (left,right) ->
        return true if left == right
        return true if (!!left && !!right) == false
        if !isNaN(left) && !isNaN(right)
          return true if parseFloat(left) == parseFloat(right)
        false
      filteredList = (bool)->
        if bool
          bool = (left,right) ->
            !!left.match(new RegExp("^" + right))
        location = elements.search[0].selectionStart || elements.search.val().length
        if functions.isPrimative
          obj = elements.search.val()[0..location - 1].replace(/^\s+/g,'') || ''
        else
          obj={}
          obj[functions.viewValue] = elements.search.val()[0..location - 1].replace(/^\s+/g,'') || ''
        return unless functions.collection(scope)
        fList = $filter('orderBy')($filter('filter')(functions.collection(scope), obj,bool), functions.viewValue)
        for filter in options.filters
          [filterType,value] = filter.replace(/\s+/,'').split(':')
          fList = $filter(filterType)(fList, value)
        fList
      buildTemplate = ->
        elements.template.empty()
        return unless filteredList()
        for item in filteredList()
          if isMobile
            li = angular.element '<li>' + functions.viewValueFn(item) + '</li>'
          else
            li = angular.element '<a class="item">' + functions.viewValueFn(item) + '</a>'
          ip = angular.element '<input type="hidden">'
          ip.val(functions.modelValueFn(item))
          ip[0].setAttribute('ng-data-type',typeof functions.modelValueFn(item))
          li.append(ip)
          li.bind 'mousedown', ($event)->
            val = ($event.target.children[0].value)["to_" + $event.target.children[0].getAttribute('ng-data-type')]()
            updateValue(val)
          elements.template.append(li)
      setInitialValue = ->
        unless isMobile
          if model = scope.$eval(attrs.ngModel)
            if functions.isPrimative
              obj = model
            else
              obj = {}
              obj[functions.modelValue] = model
            list = $filter('filter')(functions.collection(scope), obj,equiv)
            viewScope = list[0] if list
            elements.search.val(if viewScope then functions.viewValueFn(viewScope).replace(/^\s+/g,'') else '')
            elements.typeAhead.html(elements.search.val())
        else
          unless model = scope.$eval(attrs.ngModel)
            view = attrs.placeholder
            element.css('color','rgba(0,0,0,0.4)')
          else
            element.css('color','')
            if functions.isPrimative
              obj = model
            else
              obj = {}
              obj[functions.modelValue] = model
            list = $filter('filter')(functions.collection(scope), obj,true)
            viewScope = list[0] if list
            view = if viewScope then functions.viewValueFn(viewScope) else attrs.placeholder
          element.html('')
          element.html(view)

      updateValue = (model) ->
        scope.$apply ->
          ngModel.$setViewValue(model)
          elements.tempHolder.removeClass('active')
          setInitialValue()
      disabled = ->
        unless typeof fieldset != 'undefined'
          done = false
          fieldset = element
          until done
            fieldset = fieldset.parent()
            unless done = typeof fieldset[0] == 'undefined'
              done = fieldset[0].tagName == 'FIELDSET'
        return true if typeof element[0].attributes.disabled != 'undefined' || $parse(attrs.ngDisabled)(scope)
        if fieldset.length > 0
          ngdis = if fieldset[0].attributes.ngDisabled then fieldset[0].attributes.ngDisabled.value else ''
          return true if fieldset[0].attributes.disabled || $parse(ngdis)(scope)
        form = element[0]
        until form.nodeName == 'FORM' || !form
          form = form.parentNode
          break if !form
        form ||= element[0]
        return true if form.disabled
        return false

      viewOptions = JSON.parse(attrs.filterOptions || '{}')
      options     = new SelectOptions(attrs.ngSelectOptions,element[0].outerHTML)
      functions   = new SelectFunctions(options.match,$parse)
      eFunctions  = new EventFunctions(functions,buildTemplate,updateValue,filteredList,$filter,$timeout,$parse,scope,disabled,viewOptions)
      if isMobile = typeof attrs.ngMobile != 'undefined'
        elements  = new MobileTemplate(element,eFunctions.mobile())
      else
        elements  = new StandardTemplate(element,attrs,eFunctions.standard(),disabled())
      scope.$watchCollection functions.collection, (newVal,oldVal) ->
        return if newVal == oldVal
        setInitialValue()
        buildTemplate()
      scope.$watch attrs.ngModel, (newVal,oldVal) ->
        return if newVal == oldVal
        setInitialValue()
      scope.$watch disabled, (newVal) ->
        elements.search[0].disabled = newVal
      setInitialValue()
      buildTemplate()
