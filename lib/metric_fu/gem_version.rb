require 'rubygems'
module MetricFu
  class GemVersion

    def initialize
      @gem_spec = Gem::Specification.load(gemspec)
    end

    def gemspec
      gemspec = File.join(MetricFu.root_dir, 'metric_fu.gemspec')
    end

    def new_dependency(name, version)
      Gem::Dependency.new(name, version, :runtime)
    end

    def gem_runtime_dependencies
      @gem_runtime_dependencies ||= begin
                                      @gem_spec.dependencies.select{|gem| gem.type == :runtime}.each do |gem_dep|
                                        gem_dep.name = gem_dep.name.downcase.sub('metric_fu-','')
                                      end << new_dependency('rcov', ['~> 0.8'])
                                    end
    end

    def for(name)
      name.downcase!
      dep = gem_runtime_dependencies.find(unknown_dependency(name)) do |gem_dep|
        gem_dep.name == name
      end
      dep.requirements_list
    end

    def unknown_dependency(name)
      ->(name){ new_dependency(name, ['>= 0']) }
    end

    RESOLVER = new
    def self.for(name)
      RESOLVER.for(name).dup
    end

    def self.dependencies
      RESOLVER.gem_runtime_dependencies.dup
    end

    def self.dependencies_summary
      dependencies.map do |gem_dep|
        {
          'name' => gem_dep.name,
          'version' => gem_dep.requirements_list,
        }
      end
    end

  end
end
