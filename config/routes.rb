Jets.application.routes.draw do
  namespace :v1 do
	  resources :transactions, only: ['index',
	                                  'show',
	                                  'create',
	                                  'delete'] do
	    member do
	      post 'capture'
	    end
	  end
  end
  
end
