require 'delta_force/change_proxy'

module DeltaForce
  module ClassMethods

    def tracks_changes_over_time
      yield DeltaForce::ChangeProxy.new(self)
    end

    def calculates_changes_in(value_field_name, options = {})
      options = options.symbolize_keys

      value_field_name = value_field_name.to_s

      partition_field_name = options[:partition_by]
      partition_column = "#{table_name}.#{partition_field_name.to_s}"

      value_column = "#{table_name}.#{value_field_name}"
      id_column = "#{table_name}.id"

      period_field_name = options[:period] || 'period'
      period_column = "#{table_name}.#{period_field_name}"

      scope_name = "changes_in_#{value_field_name}".to_sym 

      window = "
        (
           PARTITION BY #{partition_column}
           ORDER BY #{period_column} DESC, #{id_column} DESC ROWS
           BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )"

      named_scope scope_name, :select => "distinct #{partition_column},
        last_value(#{period_column}) over #{window} as opening_#{period_field_name},
        first_value(#{period_column}) over#{window} as closing_#{period_field_name},
        last_value(#{value_column}) over #{window} as opening_#{value_field_name},
        first_value(#{value_column}) over #{window} as closing_#{value_field_name}
        "
    end
  end
end
