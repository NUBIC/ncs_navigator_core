module JsonBody
  ##
  # A memoizing shortcut for JSON.parse(last_response.body).
  def json
    @json ||= JSON.parse(last_response.body)
  end
end

Cucumber::Rails::World.send(:include, JsonBody)
