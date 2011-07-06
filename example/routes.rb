MongoidIncluded::Application.routes.draw do
  resources :invoices do
    resources :items, :module => "invoices"
  end
end