module NcsNavigator::Core::Surveyor
  ##
  # Wraps Surveyor's many value columns with a single accessor.
  #
  # This is useful for code that needs to work with response values but
  # should not care about Surveyor internals.  (Merge and prepopulation, for
  # example.)
  #
  # These accessors make great use of the answer association on Response,
  # which means that you MAY want to eager-load answer as a default scope.
  #
  #
  # Relationship to Response#reportable_value
  # -----------------------------------------
  #
  # Response#reportable_value is intended for warehouse use.  It performs
  # transformations that -- while appropriate for warehousing -- may not be
  # appropriate for more general use.  For example, #reportable_value coerces
  # all numbers to strings and returns reference identifiers of answers.  The
  # accessor defined here attempts to keep transformations to a minimum.
  module ResponseValue
    ##
    # Response columns altered by this method.
    VALUE_FIELDS = ::Response.columns.map(&:name).select { |n| n.end_with?('_value') }

    def self.included(model)
      model.before_save :write_value_to_record
    end

    ##
    # Sets a value.
    #
    # This method does not directly alter model state.  Instead, this merely
    # writes to an instance variable.  That instance variable is then persisted
    # to its corresponding column in a before-save hook.
    #
    # The rationale for this behavior:
    #
    # 1. A response value cannot be set without an answer.
    # 2. The answer may not be present at the time #value= is called.
    # 3. If #value= immediately attempts to coerce its input and an answer is
    #    not present, there is no sensible behavior but to raise an exception.
    # 4. Because of (3), we must now enforce prerequisites for usage of
    #    #value=; namely, an answer must be set before using #value=.
    # 5. However, no other model in Cases has accessors that intentionally
    #    exhibit the peculiar behavior described in (4).
    # 6. Additionally, the behavior described in (4) is really odd for
    #    ActiveRecord models and Ruby objects in general.  You should be able
    #    to set object attributes in _any_ order.
    #
    # When you set a value via #value=, you can read that value exactly as you
    # set it by invoking #value.   Once the response is saved, #value will
    # report the persisted value _after any necessary coercions have occurred_.
    # This means that you could end up seeing this behavior:
    #
    #     r = Response.new(:answer => Answer.new(:response_class => 'integer'))
    #     r.value = "42"
    #     r.value         # => "42"
    #     r.value.class   # => String
    #     r.save          # => true
    #     r.value         # => 42
    #     r.value.class   # => Fixnum
    #
    #
    # On values for non-value response classes
    # ----------------------------------------
    #
    # Some response classes don't have values.  (Answer, for example.)
    #
    # In non-production environments, attempting to set a value for such a
    # response will cause a ResponseValue::CannotSetValue exception to be
    # raised.
    #
    # In production, however, no exception is raised and the attempted setting
    # is logged at WARN level.  Rationale: it's possible that this may result
    # from malicious intent, and the error is entirely recoverable (i.e. by not
    # doing anything).
    def value=(v)
      @value = v
      @value_set = true
      @value
    end

    ##
    # Retrieves a value.
    #
    # Behavior:
    #
    # 1. If the response's value was made dirty via #value=, then this returns
    #    the object passed to #value=.
    # 2. If the response's value was made dirty via some other mechanism (say, by
    #    directly setting the underlying value columns), then this returns the
    #    dirty value of the response's corresponding value column.
    # 3. If the response's value is not dirty, then this returns the persisted
    #    value of the response's corresponding value column.
    def value
      if @value_set
        @value
      else
        value_from_response
      end
    end

    def reload(*)
      remove_instance_variable(:@value)
      remove_instance_variable(:@value_set)
      super
    end

    private

    def value_from_response
      rc = answer.response_class

      as(rc) if has_value?(rc)
    end

    def write_value_to_record
      return unless @value_set

      # before_save callbacks run after before_validation callbacks, and
      # Surveyor installs a presence check on answer_id, so we know that we
      # have an answer if we get this far.
      k = answer.response_class

      field = value_field_for(k, value)

      if field
        reset_values
        send("#{field}=", value)
      else
        msg = "A value was set for response #{id}, but the response has non-value response class #{k.inspect}.  The value will not be set."

        if Rails.env.production?
          Rails.logger.warn msg
        else
          raise CannotSetValue, msg
        end
      end
    end

    def reset_values
      VALUE_FIELDS.each { |f| send("#{f}=", nil) }
    end

    module_function

    def has_value?(rc)
      # Yes, the value is used in some cases to determine an appropriate value
      # field.  However, so long as you get *some* non-nil value out of
      # value_field_for for (response class, nil), it doesn't matter what that
      # value is.
      value_field_for(rc, nil)
    end

    # Notes:
    #
    # Surveyor's Response#date_value= is defined as
    #
    #   def date_value=(val)
    #     self.datetime_value = Time.zone.parse(val).to_datetime
    #   end
    #
    # Now:
    #
    # 1. Time.zone.parse cannot accept Dates, so this will fail if we just
    #    use #date_value=.
    # 2. Surveyor::ActsAsResponse#as returns a Date for answers of response
    #    class date.
    # 3. Response#date_value doesn't actually return a Date; it gives you
    #    back a String in YYYY-MM-DD form or nil.
    #
    # The existence of fact #3 means that I'm not really sure what to do
    # when returning a date value, but as #as is used to implement #value,
    # it seems like it's consistent (or at least intelligent) to also
    # accept Dates here.  To do that, we need to use
    # Response#datetime_value=.
    def value_field_for(rc, v)
      case rc
      when 'datetime';  'datetime_value'
      when 'date';       Date === v ? 'datetime_value' : 'date_value'
      when 'time';      'time_value'
      when 'float';     'float_value'
      when 'integer';   'integer_value'
      when 'string';    'string_value'
      when 'text';      'text_value'
      end
    end

    class CannotSetValue < StandardError
    end
  end
end
