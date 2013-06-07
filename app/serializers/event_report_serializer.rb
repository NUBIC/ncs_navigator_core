class EventReportSerializer < ActiveModel::Serializer
  has_many :rows, :key => :events, :serializer => EventReportRowSerializer

  self.root = false

  def attributes
    super.tap do |h|
      h['data_collectors'] = []
      h['filters'] = {}
    end
  end
end
