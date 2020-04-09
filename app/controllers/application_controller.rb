class ApplicationController < Jets::Controller::Base
  
  protected
    def set_account
      client_id = request.env["adapter.event"]["requestContext"]["authorizer"]["claims"]["client_id"]
      @account = Account.find_by_client_id(client_id)
      pp "MeuOvo"
      pp @account
    end
end
