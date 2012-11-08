##
# Helpers for setting up Rack::Test to do API requests.
module ApiRequests

  ##
  # Given a table of the form
  #
  #     | bar                 | qux              |
  #     | header:Content-Type | application/json |
  #     | header:X-Client-ID  | 1234567890       |
  #     | qux                 | baz              |
  #
  # converts it into two hashes:
  #
  #     params, headers = params_and_headers_from_table(table)
  #
  #     params    # => { 'foo' => 'baz', 'qux' => 'baz' }
  #     headers   # => { 'X-Client-ID' => '1234567890',
  #               #      'Content-Type' => 'application/json' }
  def params_and_headers_from_table(table)
    params = {}
    headers = {}

    table.rows_hash.each do |k, v|
      if k.starts_with?('header:')
        header k.split(':', 2).last, v
      else
        params[k] = v
      end
    end

    [params, headers]
  end
end

Cucumber::Rails::World.send(:include, ApiRequests)
