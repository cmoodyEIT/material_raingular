# //= require extensions
# //= require angular
# //= require angular-route
# //= require angular-resource
# //= require angular-messages
# //= require angular-animate
# //= require angular-aria
# //= require angular-material.min
# //= require material_filters
# //= require material_raingular/factories
# //= require factory_name
# //= require_tree ./directives
# //= require js-routes
# //= require dateconverter
# //= require ajax_errors
# //= require identifier_interceptor
# //= require rails_updater

angular.module('materialRaingular', ['AutoComplete', 'NgDownload', 'NgChangeOnBlur', 'NgDrag', 'NgAuthorize', 'AComplete'
                                    'NgRepeatList', 'NgUpdate', 'NgPopup', 'NgBoolean', 'Table', 'NgWatchShow', 'NgTrackBy'
                                    'NgUpload', 'NgDestroy', 'NgCreate', 'Video','NgAuthorize', 'TextArea', 'MdUpdate'
                                    'NgSlide', 'NgMatches','NgFade','NgSwipe', 'NgLoad', 'NgWatchContent', 'RailsUpdater'
                                    'ngRoute', 'ngMaterial', 'ngMessages', 'ngResource', 'materialFilters', 'NgCallback'
                                    'NgSortable'])
