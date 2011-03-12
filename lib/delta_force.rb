require 'delta_force/class_methods'

module DeltaForce
end

ActiveRecord::Base.extend DeltaForce::ClassMethods
