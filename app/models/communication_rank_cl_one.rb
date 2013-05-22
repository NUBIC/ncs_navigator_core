# Helper methods for dealing with the COMMUNICATION_RANK_CL1 code list
#
module CommunicationRankCLOne
  ORDER = [1, 2, -5, 3, 4, -4].map do |rank|
    NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', rank)
  end

  ##
  # Returns index of the COMMUNICATION_RANK_CL1 that can be used
  # by sort_by to rank from MOST -> LEAST important.
  # @return[Integer]
  def self.sort_by_index(rank)
    ORDER.index(rank)
  end
end