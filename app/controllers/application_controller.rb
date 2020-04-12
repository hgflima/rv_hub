class ApplicationController < Jets::Controller::Base
  
  protected

    def set_account
      client_id = request.env["adapter.event"]["requestContext"]["authorizer"]["claims"]["client_id"]
      @account = Account.find_by_client_id(client_id)
    end

    def set_pagination_params
      @page     = params[:page].nil? ?  ENV['DEFAULT_PAGE_NUMBER'].to_i : params[:page].to_i
      @per_page = params[:per_page].nil? ? ENV['DEFAULT_ITEMS_PER_PAGE'].to_i : params[:per_page].to_i
    end

    def set_headers(headers)
    	headers.each { | key, value | response.set_header(key, value) }
    end

end
