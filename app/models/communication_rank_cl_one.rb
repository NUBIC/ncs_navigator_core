# Helper methods for dealing with the COMMUNICATION_RANK_CL1 code list
#
module CommunicationRankCLOne
  ##
  # @private
  # TODO: if this is ever used as a mixin, use a less generic name
  def self.order
    @order ||= [1, 2, 3, 4, -5, -4].map do |rank|
      NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', rank)
    end
  end

  ##
  # Returns index of the COMMUNICATION_RANK_CL1 that can be used
  # by sort_by to rank from MOST -> LEAST important.
  #
  # If rank not found is RANK, size is returned
  #
  # @return[Integer]
  def self.sort_by_index(rank)
    order.include?(rank) ? order.index(rank) : order.size
  end
end
