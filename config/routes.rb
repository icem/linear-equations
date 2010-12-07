ActionController::Routing::Routes.draw do |map|
  map.root :controller => :matrices, :action => :index  
  map.resources :matrices

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
