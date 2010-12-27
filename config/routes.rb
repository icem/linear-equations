ActionController::Routing::Routes.draw do |map|
  map.root :controller => :matrices, :action => :index  
  map.resources :matrices

  map.about "/about", :controller => :about, :action => :index
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
