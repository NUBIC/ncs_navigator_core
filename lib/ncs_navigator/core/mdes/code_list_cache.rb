module NcsNavigator::Core::Mdes
  ##
  # A trivial cache of {NcsCode} instances. A code list is read on first use
  # from the database. Thereafter it is used from memory only.
  class CodeListCache
    attr_reader :code_lists
    protected :code_lists

    def initialize
      reset
    end

    ##
    # Clears the cache to force reloads of all code lists. Should be needed only
    # in testing.
    def reset
      @code_lists = {}
    end

    ##
    # @return [Array<NcsCode>,nil] all the NcsCode instances for the list or nil
    #   if the list is unknown.
    def code_list(list_name)
      clear_if_classes_reloaded(list_name) unless Rails.configuration.cache_classes

      if code_lists.has_key?(list_name)
        code_lists[list_name]
      else
        cl = NcsCode.where(:list_name => list_name).order(:local_code).all.each(&:freeze)
        code_lists[list_name] = cl.empty? ? nil : cl.freeze
      end
    end

    ##
    # @return [NcsCode,nil] the matching instance or nil
    def code_value(list_name, local_code)
      cl = code_list(list_name)
      return nil unless cl
      cl.find { |ncs_code| ncs_code.local_code == local_code }
    end

    def clear_if_classes_reloaded(list_name)
      list = code_lists[list_name]
      if list && list.detect { |entry| entry.class != NcsCode }
        code_lists.delete(list_name)
      end
    end
    private :clear_if_classes_reloaded
  end
end
