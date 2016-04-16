module Xpub
  module DslAccessor
    def dsl_accessor(name, *arg)
      define_method(name) do |*iarg|
        if iarg.empty?
          if !instance_variable_defined?("@#{name}") && arg[0] && arg[0][:default]
            instance_variable_set("@#{name}", arg[0][:default])
          end
          instance_variable_get("@#{name}")
        else
          instance_variable_set("@#{name}", iarg[0])
        end
      end
    end
  end
end

class Class
  include Xpub::DslAccessor
end
