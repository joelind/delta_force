
module DeltaForce
  class ChangeProxy

    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def values(*value_fields)
      options = value_fields.extract_options!.symbolize_keys

      partition_column = "#{table_name}.#{options[:by].to_s}"
      id_column = "#{table_name}.id"

      period_field_name = options[:over].to_s
      period_column = "#{table_name}.#{period_field_name}"

      scope_name = options[:scope_name] || default_scope_name(value_fields, options)

      window = "
        (
           PARTITION BY #{partition_column}
           ORDER BY #{period_column} DESC, #{id_column} DESC ROWS
           BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )"

      value_expressions = value_fields.collect do |value_field|
        value_field_name = value_field.to_s
        value_column = "#{table_name}.#{value_field_name}"

        [
          "last_value(#{value_column}) over #{window} as opening_#{value_field_name}",
          "first_value(#{value_column}) over #{window} as closing_#{value_field_name}"
        ]
      end.flatten

      klass.named_scope scope_name, :select => "distinct #{partition_column},
        last_value(#{period_column}) over #{window} as opening_#{period_field_name},
        first_value(#{period_column}) over #{window} as closing_#{period_field_name},
        #{value_expressions.join ','}
      "
    end

    alias :value :values

    private

    def default_scope_name(value_fields, options)
      value_fields = value_fields.map(&:to_s).sort
      period = options[:over].to_s
      partition = options[:by].to_s

      value_fields = value_fields.to_sentence(:words_connector => '_and_',
                                              :two_words_connector => '_and_',
                                              :last_word_connector => '_and_')

      "changes_in_#{value_fields}_by_#{partition}_over_#{period}"
    end

    def table_name
      klass.table_name
    end

    def calculate_changes(value_field_name, options = {})
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
        first_value(#{period_column}) over #{window} as closing_#{period_field_name},
        last_value(#{value_column}) over #{window} as opening_#{value_field_name},
        first_value(#{value_column}) over #{window} as closing_#{value_field_name}
        "
    end
  end
end
