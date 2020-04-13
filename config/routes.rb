Jets.application.routes.draw do
  resources :transactions, authorizer: "main#RvHubCognito", authorization_scopes: %w[meuOvo meuovo1], only: ['index',
                                  'show',
                                  'create',
                                  'delete'] do
    member do
      post 'capture', authorizer: "main#RvHubCognito", authorization_scopes: %w[teste testinho]
    end
  end
end
