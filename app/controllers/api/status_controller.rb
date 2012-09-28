class Api::StatusController < ActionController::Base
  def show
    # Check database connection
    db_ok = begin
              !ActiveRecord::Base.connection.execute('SELECT 1').nil?
            rescue Exception
              false
            end

    ok = db_ok

    render :json => { 'db' => db_ok }, :status => ok ? :ok : :internal_server_error
  end
end
