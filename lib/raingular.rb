require "raingular/version"

module Raingular
  module Rails
    class Engine < ::Rails::Engine
      spec.add_runtime_dependency 'angular-rails-templates'
    end
  end
end
