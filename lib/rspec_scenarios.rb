require 'spec'
require 'spec/interop/test'

module Spec
  module Scenarios
    def load(group_name, scenario_name, instance=nil)
      group_name = group_name.to_s
      require File.join( 'spec/scenarios' , group_name )
      klass = group_name.camelize.constantize.new

      klass.send(scenario_name)
      if instance
        klass.instance_variables.each do |iv|
          instance.instance_variable_set(iv, klass.instance_variable_get(iv)) 
        end
      end
      klass
    end
    module_function :load

    module ArrayMethods
      def save!()
        each{ |i| i.save! }
        if size == 1
          self[0]
        else
          self
        end
      end

      def spec_save!()
        each{ |i| i.spec_save! }
        if size == 1
          self[0]
        else
          self
        end
      end
      
      alias_method :save, :save!
      alias_method :spec_save, :spec_save!
    end

    module ExampleMethods
      # New method to load fixtures and create locally-bound instance variables
      def load_scenario(group_name, *scenario_names)        
        scenario_names.each { |n| 
          Scenarios::load(group_name, n, self) 
        }
      end
    end
  end
end

module Spec
  module Example
    module ExampleGroupMethods
      include Spec::Scenarios::ExampleMethods
    end
  end
end

class Test::Unit::TestCase
  include Spec::Scenarios::ExampleMethods
end

class Array
  include Spec::Scenarios::ArrayMethods
end

