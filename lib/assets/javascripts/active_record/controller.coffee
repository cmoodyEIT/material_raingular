class @ActiveRecord.Controller extends AngularServiceModel
  @$inject: ['$paramSerializer','$http']
  new:     (params,callback,error) -> @$singleRecord(params,'new','GET',callback,error)
  create:  (params,callback,error) -> @$singleRecord(params,'create','POST',callback,error)
  show:    (params,callback,error) -> @$singleRecord(params,'show','GET',callback,error)
  edit:    (params,callback,error) -> @$singleRecord(params,'edit','GET',callback,error)
  update:  (params,callback,error) -> @$singleRecord(params,'update','PUT',callback,error)
  destroy: (params,callback,error) -> @$singleRecord(params,'destroy','DELETE',callback,error)
  index:   (params,callback,error) -> @$collectionRecord(params,'index','GET',callback,error)

  # Privte
  __name__: -> @constructor.toString().match(/function\s*(.*?)\(/)?[1]
  __table_name__: -> @__name__().tableize()
  __url__: -> '/' + @__table_name__() + '/:id'
  $rawUrl: (params,route,method)->
    method ||= 'GET'
    @$buildUrls() unless @_urls
    key = Object.keys(params || {}).intersection(Object.keys(@_urls))[0]
    path = @_urls[key][route] if key && route
    path ||= @__url__()
    replacements = {new: 'new',edit: ':id/edit'}
    path = path.replace(':id',replacements[route]) if route in Object.keys(replacements)
    additionals={}
    for key,val of (params || {})
      newPath = path.replace(':' + key, val)
      additionals[key] = val if newPath == path
      path = newPath
    [path,additionals]
  $url: (params,route,method)->
    [path,additionals] = @$rawUrl(params,route,method)
    path   = path.split('/').reject( (item)-> item[0] == ':').join('/')
    path  += '.json' unless path.match(/\.json$/)
    if method == 'GET'
      query  = @$paramSerializer.clean(additionals)
      path  += '?' + query if query
    path

  routes:
    shallow:    ['edit','update','show','destroy']
    nonShallow: ['new','create','index']
    restful:    ['new','create','index','edit','update','show','destroy']
  $buildUrls: ->
    @_urls ||= {}
    for item in [@parents].compact().flatten()
      atom = if typeof item == 'string' then item else Object.keys(item)[0]
      foreignKey = item[atom]?.foreignKey || atom + '_id'
      @_urls[foreignKey] ||= {}
      for key in @routes.restful
        continue if key not in (item[atom]?.only || []) && item[atom]?.only
        shallow = key in @routes.shallow && (item[atom]?.shallow)
        @_urls[foreignKey][key]  = if shallow then '' else '/' + atom.pluralize() + '/:' + foreignKey
        @_urls[foreignKey][key] += @__url__()
  $singleRecord: (params,route,method,callback,error)     -> @$fetchRecord(params,route,method,callback,error,'$Resource')
  $collectionRecord: (params,route,method,callback,error) -> @$fetchRecord(params,route,method,callback,error,'$Collection')
  $fetchRecord: (params,route,method,callback,error,type,update_url,destroy_url) ->
    if typeof params == 'function'
      error = callback
      callback = params
      params = {}
    url = if route in @routes.restful then @$url(params,route,method) else route
    promise = @$http(url: url, method: method, data: params)
    update_url  ?= @$rawUrl(params,'update','PUT')[0]
    destroy_url ?= @$rawUrl(params,'destroy','DELETE')[0]
    new ActiveRecord[type](promise,callback,error,update_url,destroy_url)
  @$addRoutes: (routes) ->
    for key,val of routes
      @::[key] = (params,callback,error)->
        type = if val.collection then '$Collection' else '$Resource'
        @$fetchRecord(params,val.url,(val.method || 'GET'),callback,error,type,val.update_url,val.destroy_url)
# @Company.employees(id: company.id) => '/companies/:id/employees'

###
Desired Syntax
class ActiveRecord.Project extends ActiveRecord.Base
  @register(angular.app)
  @parents: [{company: {shallow: true}},{person: {only: ['index']},'organization'] # Non-Shallow routes index,create,new Shallow routes update,edit,show,destroy
  # Alternate function snytax:
  @parents: ->[{company: {shallow: true}},{person: {only: ['index']},'organization']

resulting functionality
# New
@Project.new()                             => /projects/new.json                    #Method => GET
@Project.new(company_id: 1)                => /companies/1/projects/new.json        #Method => GET
@Project.new(person_id: 1)                 => /projects/new.json?person_id=1        #Method => GET
@Project.new(organization_id: 1)           => /organizations/1/projects/new.json    #Method => GET
# Create
@Project.create()                          => /projects.json                        #Method => POST
@Project.create(company_id: 1)             => /companies/1/projects.json            #Method => POST
@Project.create(person_id: 1)              => /projects.json?person_id=1            #Method => POST
@Project.create(organization_id: 1)        => /organizations/1/projects.json        #Method => POST
# Edit
@Project.edit(id: 3)                       => /projects/3/edit.json                 #Method => GET
@Project.edit(id: 3,company_id: 1)         => /projects/3/edit.json?company_id=1    #Method => GET
@Project.edit(id: 3,person_id: 1)          => /projects/3/edit.json?person_id=1     #Method => GET
@Project.edit(id: 3,organization_id: 1)    => /organizations/1/projects/3/edit.json #Method => GET
# Update
@Project.update(id: 3)                     => /projects/3.json                      #Method => PUT/PATCH
@Project.update(id: 3,company_id: 1)       => /projects/3.json?company_id=1         #Method => PUT/PATCH
@Project.update(id: 3,person_id: 1)        => /projects/3.json?person_id=1          #Method => PUT/PATCH
@Project.update(id: 3,organization_id: 1)  => /organizations/1/projects/3.json      #Method => PUT/PATCH
# Show
@Project.show(id: 3)                       => /projects/3.json                      #Method => GET
@Project.show(id: 3,company_id: 1)         => /projects/3.json?company_id=1         #Method => GET
@Project.show(id: 3,person_id: 1)          => /projects/3.json?person_id=1          #Method => GET
@Project.show(id: 3,organization_id: 1)    => /organizations/1/projects/3.json      #Method => GET
# Destroy
@Project.destroy(id: 3)                    => /projects/3.json                      #Method => DELETE
@Project.destroy(id: 3,company_id: 1)      => /projects/3.json?company_id=1         #Method => DELETE
@Project.destroy(id: 3,person_id: 1)       => /projects/3.json?person_id=1          #Method => DELETE
@Project.destroy(id: 3,organization_id: 1) => /organizations/1/projects/3.json      #Method => DELETE
# Index
@Project.index()                           => /projects.json                        #Method => GET
@Project.index(company_id: 1)              => /companies/1/projects.json            #Method => GET
@Project.index(person_id: 1)               => /people/1/projects.json               #Method => GET
@Project.index(organization_id: 1)         => /organizations/1/projects.json        #Method => GET

Desired Syntax
class ActiveRecord.Project extends ActiveRecord.Base
  @register(angular.app)
  @__url__: -> '/not_projects'
  @parents: [{company: {shallow: true}}]

resulting functionality
# New
@Project.new()                             => /not_projects/new.json                    #Method => GET
@Project.new(company_id: 1)                => /companies/1/not_projects/new.json        #Method => GET
# Create
@Project.create()                          => /not_projects.json                        #Method => POST
@Project.create(company_id: 1)             => /companies/1/not_projects.json            #Method => POST
# Edit
@Project.edit(id: 3)                       => /not_projects/3/edit.json                 #Method => GET
@Project.edit(id: 3,company_id: 1)         => /not_projects/3/edit.json?company_id=1    #Method => GET
# Update
@Project.update(id: 3)                     => /not_projects/3.json                      #Method => PUT/PATCH
@Project.update(id: 3,company_id: 1)       => /not_projects/3.json?company_id=1         #Method => PUT/PATCH
# Show
@Project.show(id: 3)                       => /not_projects/3.json                      #Method => GET
@Project.show(id: 3,company_id: 1)         => /not_projects/3.json?company_id=1         #Method => GET
# Destroy
@Project.destroy(id: 3)                    => /not_projects/3.json                      #Method => DELETE
@Project.destroy(id: 3,company_id: 1)      => /not_projects/3.json?company_id=1         #Method => DELETE
# Index
@Project.index()                           => /not_projects.json                        #Method => GET
@Project.index(company_id: 1)              => /companies/1/not_projects.json            #Method => GET

Desired Syntax
class ActiveRecord.Project extends ActiveRecord.Base
  @register(angular.app)
  @__url__: -> '/not_projects'
  @parents: [{company: {shallow: true, url: '/not_companies/:id/something'}}]

resulting functionality
# New
@Project.new(company_id: 1)                => /not_companies/1/something/new.json        #Method => GET
# Create
@Project.create(company_id: 1)             => /not_companies/1/something.json            #Method => POST
# Edit
@Project.edit(id: 3,company_id: 1)         => /not_projects/3/edit.json?company_id=1    #Method => GET
# Update
@Project.update(id: 3,company_id: 1)       => /not_projects/3.json?company_id=1         #Method => PUT/PATCH
# Show
@Project.show(id: 3,company_id: 1)         => /not_projects/3.json?company_id=1         #Method => GET
# Destroy
@Project.destroy(id: 3,company_id: 1)      => /not_projects/3.json?company_id=1         #Method => DELETE
# Index
@Project.index(company_id: 1)              => /not_companies/1/something.json            #Method => GET


###
