Jets.application.routes.draw do
  resources :transactions, only: ['index',
                                  'show',
                                  'create',
                                  'delete'] do
    member do
      post 'capture'
    end
  end
end
