namespace :raingular do
  desc "Generate Raingular Factories"
  task factories: :environment do
    puts "Rewriting angular factories:"
    controllers = HashWithIndifferentAccess.new
    factories = "angular.factories = angular.module('Factories', [])\n"
    Rails.application.routes.routes.each do |route|
      unless route.constraints[:request_method].nil? || route.defaults[:controller].nil?
        controllers[route.defaults[:controller]] ||= {}
        controllers[route.defaults[:controller]][:parent_model_name_and_format_symbol] ||= []
        controllers[route.defaults[:controller]][:parent_model_name_and_format_symbol] |= route.parts
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
        factories += "    #{action}:   { method: '#{route[:method]}', url: '#{route[:url]}'  },"
      end
      factories    = factories[0...-1] + "});});\n"
    end
    dirname = "#{Rails.root}/vendor/assets/javascripts/raingular"
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    File.write("#{Rails.root}/vendor/assets/javascripts/raingular/factories.js" ,Uglifier.compile(factories,mangle: false))
  end
end
namespace :db do
  task :migrate do
     Rake::Task["raingular:factories"].invoke
  end
end