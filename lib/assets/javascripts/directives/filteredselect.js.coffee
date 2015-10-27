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
      viewValueFn  = $parse(viewValue || modelValue)
      modelValueFn = $parse(modelValue || viewValue)
      template     = angular.element("<ul> </ul>")
      if isMobile = typeof attrs.ngMobile != 'undefined'
        search       = angular.element "<input type='search' placeholder='Search'>"
        tempHolder   = angular.element("<div class='filtered-select' ></div>")
        tempHolder.addClass('bottom') if element.hasClass('bottom')
        body = angular.element(document.body)
        body.bind 'keydown', (event) ->
          tempHolder.removeClass('active') if event.keyCode == 27
        tempHolder.append search
        tempHolder.append template
        body.append tempHolder
      else
        span         = angular.element "<span></span>"
        search       = angular.element "<input class='autocomplete' type='search' placeholder='" + attrs.placeholder + "'>"
        tempHolder   = angular.element "<div class='autocomplete menu md-whiteframe-z1'>"
        span.append search
        span.append tempHolder
        element.append span
        tempHolder.append template

      ulHeight = ->
        full = window.innerHeight
        full = full/3 if element.hasClass('bottom')
        full - search[0].offsetHeight + 'px'
      template.css('height',ulHeight()) if isMobile
      scope.$watchCollection collection, (newVal,oldVal) ->
        return if newVal == oldVal
        setInitialValue()
        buildTemplate()
      scope.$watch attrs.ngModel, (newVal,oldVal) ->
        return if newVal == oldVal
        setInitialValue()
      search.bind 'input', ->
        buildTemplate()
      buildTemplate = ->
        template.empty()
        obj={}
        obj[viewValue] = search.val() || ''
        return unless collection(scope)
        filteredList = $filter('orderBy')($filter('filter')(collection(scope), obj), viewValue)
        for filter in filters
          [filterType,value] = filter.replace(/\s+/,'').split(':')
          filteredList = $filter(filterType)(filteredList, value)
        for item in filteredList
          if isMobile
            li = angular.element '<li>' + viewValueFn(item) + '</li>'
          else
            li = angular.element '<a class="item">' + viewValueFn(item) + '</a>'
          ip = angular.element '<input type="hidden">'
          ip.val(modelValueFn(item))
          li.append(ip)
          li.bind 'mousedown', ($event)->
            updateValue($event.target.children[0].value)
          template.append(li)
      setInitialValue = ->
        unless isMobile
          obj = {}
          obj[modelValue] = ngModel.$modelValue
          list = $filter('filter')(collection(scope), obj,true)
          viewScope = list[0] if list
          search.val(if viewScope then viewValueFn(viewScope) else '')
        else
          unless model = ngModel.$modelValue
            view = attrs.placeholder
            element.css('color','rgba(0,0,0,0.4)')
          else
            element.css('color','')
            obj = {}
            obj[modelValue] = model
            list = $filter('filter')(collection(scope), obj,true)
            viewScope = list[0] if list
            view = if viewScope then viewValueFn(viewScope) else attrs.placeholder
          element.html('')
          element.html(view)

      setInitialValue()
      buildTemplate()
      updateValue = (model) ->
        ngModel.$setViewValue(model)
        tempHolder.removeClass('active')
        $timeout ->
          setInitialValue() unless isMobile
      done = false
      fieldset = element
      until done
        fieldset = fieldset.parent()
        unless done = typeof fieldset[0] == 'undefined'
          done = fieldset[0].tagName == 'FIELDSET'
      element.parent('fieldset')
      if isMobile
        element.bind 'mousedown', (event)->
          return if tempHolder.hasClass('active')
          return if attrs.disabled || $parse(attrs.ngDisabled)(scope)
          if fieldset.length > 0
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
