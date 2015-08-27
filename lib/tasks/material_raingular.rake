namespace :material_raingular do
  desc "Generate Material Raingular Factories"
  task factories: :environment do
    variances = Rails.application.config.raingular_variances rescue {}
    puts "Rewriting angular factories:"
    factories = "angular.factories = angular.module('Factories', [])\n"
    controllers = HashWithIndifferentAccess.new
    Rails.application.routes.routes.each do |route|
      unless route.constraints[:request_method].nil? || route.defaults[:controller].nil? || (route.app.constraints.present? rescue false)
        controllers[route.defaults[:controller]] ||= {}
        controllers[route.defaults[:controller]][:parent_model_name_and_format_symbol] ||= []
        controllers[route.defaults[:controller]][:parent_model_name_and_format_symbol] |= route.parts
        (route.parts - [:id, :format]).each do |parent|
          action  = route.defaults[:action].to_sym
          method  = [:index, :show].include?(action) ? '' : "#{action}_"
          method += route.defaults[:controller].send(action == :index ? :pluralize : :singularize)
          controllers[parent[0..-4].pluralize] ||= {}
          controllers[parent[0..-4].pluralize][method] = {url: route.path.spec.to_s.gsub('(.:format)',''), method: route.constraints[:request_method].inspect.delete('/^$')}
        end
        controllers[route.defaults[:controller]][route.defaults[:action]] = {url: route.path.spec.to_s.gsub('(.:format)',''), method: route.constraints[:request_method].inspect.delete('/^$')}
      end
    end
    controllers.each do |controller,routes|
      parts        = routes.delete(:parent_model_name_and_format_symbol)
      parts.delete(:format)
      ids          = parts.map{|p| "#{p.to_sym}: '@#{p}'"}.join(', ')
      factories   += "angular.factories.factory('#{controller.try(:classify)}', function($resource) {return $resource("
      factories   += "'/#{controller}/:id.json', {#{ids}},{"
      routes.each do |action,route|
        ary = action.to_sym != :create && action.to_sym != :new && !(route[:url] =~ /\/:id/)
        if (variances[controller.to_sym][action.to_sym].present? rescue false)
          ary = variances[controller.to_sym][action.to_sym][:array]
        end
        factories += "    #{action}:   { method: '#{route[:method]}', url: '#{route[:url]}.json', isArray: #{ary}  },"
      end
      factories    = factories[0...-1] + "});});\n"
    end
    dirname = Rails.root.join("vendor","assets","javascripts","material_raingular")
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    File.write(dirname.join("factories.js") ,Uglifier.compile(factories,mangle: false))
  end
end
namespace :db do
  task :migrate do
     Rake::Task["material_raingular:factories"].invoke
  end
end
