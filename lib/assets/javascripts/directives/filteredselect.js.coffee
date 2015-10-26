REGEXP = /^\s*([\s\S]+?)(?:\s+as\s+([\s\S]+?))?(?:\s+group\s+by\s+([\s\S]+?))?(?:\s+disable\s+when\s+([\s\S]+?))?\s+for\s+(?:([\$\w][\$\w]*)|(?:\(\s*([\$\w][\$\w]*)\s*,\s*([\$\w][\$\w]*)\s*\)))\s+in\s+([\s\S]+?)(?:\s+track\s+by\s+([\s\S]+?))?$/;
      # 1: Model Value
      # 2: Display Value
      # 3: group by expression (groupByFn)
      # 4: disable when expression (disableWhenFn)
      # 5: Repeater
      # 6: object item key variable name
      # 7: object item value variable name
      # 8: collection
      # 9: track by expressionj

angular.module('FilteredSelect', [])
  .directive 'ngFilteredSelect', ($parse,$filter,$timeout)->
    require: 'ngModel'
    link: (scope,element,attrs,ngModel) ->
      filters = attrs.ngSelectOptions.split('|')
      options = filters.shift()
      match = options.match(REGEXP);
      if !match
        throw new Error(
          "Expected expression in form of " +
          "'_select_ (as _label_)? for (_key_,)?_value_ in _collection_'" +
          " but got '" + attrs.ngSelectOptions + "'. Element: " + element[0].outerHTML)
      collection   = $parse(match[8])
      modelValue   = match[1].replace(match[5] + '.','')
      viewValue    = if match[2] then match[2].replace(match[5] + '.','') else modelValue
      template     = angular.element("<ul> </ul>")
      search       = angular.element "<input type='search' placeholder='Search'>"
      tempHolder   = angular.element("<div class='filtered-select' ></div>")
      viewValueFn  = $parse(viewValue || modelValue)
      modelValueFn = $parse(modelValue || viewValue)
      tempHolder.addClass('bottom') if element.hasClass('bottom')
      template.bind 'mousewheel DOMMouseScroll', (event)->
        delta = event.wheelDelta or event.originalEvent and event.originalEvent.wheelDelta or -event.detail
        bottomOverflow = template[0].scrollTop + template.outerHeight() - template[0].scrollHeight >= 0
        topOverflow = template[0].scrollTop <= 0
        if delta < 0 and bottomOverflow or delta > 0 and topOverflow
          event.preventDefault()
      scrollStart = null
      scrollTop   = null
      template.bind 'touchstart', (event)->
        event.stopPropagation()
        scrollStart = event.originalEvent.touches[0].clientY
      template.bind 'touchmove', (event) ->
        event.stopPropagation()
        scroll = event.originalEvent.touches[0].clientY
        scrollStart = scroll unless scrollStart
        if scroll > scrollStart
          event.preventDefault() if template.scrollTop() == 0
        else if scroll < scrollStart
          newScrollTop = template.scrollTop()
          event.preventDefault() if scrollTop == newScrollTop
          scrollTop = newScrollTop
        scrollStart = scroll
        return true
      template.bind 'touchend', ->
        event.stopPropagation()
        scrollStart = null
      body = angular.element('body')
      body.bind 'keydown', (event) ->
        tempHolder.removeClass('active') if event.keyCode == 27
      tempHolder.append search
      tempHolder.append template
      body.append tempHolder
      ulHeight = ->
        full = window.innerHeight
        full = full/3 if element.hasClass('bottom')
        full - search[0].offsetHeight + 'px'
      template.css('height',ulHeight())
      scope.$watch collection, (newVal,oldVal) ->
        return if newVal == oldVal
        setInitialValue()
        buildTemplate()
      scope.$watch attrs.ngModel, (newVal,oldVal) ->
        return if newVal == oldVal
        setInitialValue()
      search.bind 'input', ->
        buildTemplate()
      buildTemplate = ->
        list= []
        obj={}
        obj[viewValue] = search.val() || ''
        return unless collection(scope)
        filteredList = $filter('orderBy')($filter('filter')(collection(scope), obj), viewValue)
        for filter in filters
          [filterType,value] = filter.replace(/\s+/,'').split(':')
          filteredList = $filter(filterType)(filteredList, value)
        for item in filteredList
          li = angular.element '<li ng-model-value="' + modelValueFn(item) + '">' + viewValueFn(item) + '</li>'
          li.bind 'mousedown', ($event)->
            updateValue($event.target.attributes['ng-model-value'].value)
          list.push li
        template.empty()
        template.append(list)
      setInitialValue = ->
        unless model = ngModel.$modelValue
          view = attrs.placeholder
          element.css('color','rgba(0,0,0,0.4)')
        else
          element.css('color','')
          obj = {}
          obj[modelValue] = model
          list = $filter('filter')(collection(scope), obj)
          viewScope = list[0] if list
          view = if viewScope then viewValueFn(viewScope) else attrs.placeholder
        element.html('')
        element.html(view)
      setInitialValue()
      buildTemplate()
      updateValue = (model) ->
        ngModel.$setViewValue(model)
        tempHolder.removeClass('active')
      done = false
      fieldset = element
      until done
        fieldset = fieldset.parent()
        unless done = typeof fieldset[0] == 'undefined'
          done = fieldset[0].tagName == 'FIELDSET'
      element.parent('fieldset')
      element.bind 'mousedown', (event)->
        return if tempHolder.hasClass('active')
        return if attrs.disabled || $parse(attrs.ngDisabled)(scope)
        if fieldset
          ngdis = if fieldset[0].attributes.ngDisabled then fieldset[0].attributes.ngDisabled.value else ''
          return if fieldset[0].attributes.disabled || $parse(ngdis)(scope)
        search.val('')
        buildTemplate()
        tempHolder.css('top',event.clientY)
        tempHolder.css('transition','none')
        $timeout ->
          tempHolder.css('transition','')
          tempHolder.css('top','')
          tempHolder.addClass('active')
