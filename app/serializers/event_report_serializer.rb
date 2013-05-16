class EventReportSerializer < ActiveModel::Serializer
  has_many :rows, :key => :events, :serializer => EventReportRowSerializer

  def attributes
    super.tap do |h|
      h['data_collectors'] = []
      h['filters'] = {}
    end
  end
end
