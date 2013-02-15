Juggernaut::Application.routes.draw do
  match '/api/annotations/s3_store' => 'api/annotations#s3_store'
  
  namespace :api do
    resources :users
    resources :tasks
    resources :subjects do
      collection do
        get :next_subject_for_workflow
        get :next_subject_for_classification
        get :get_image_for_battle
      end
    end
    
    resources :classifications
    resources :annotations
    resources :favourites
  end
  
  namespace :public do
    resources :users do
      resources :classifications
      resources :favourites
    end
    
    resources :classifications
    resources :favourites
    resources :subjects
  end
  
  resources :dashboard
  
  match '/classify' => 'workflows#classify', :as => :classify
  match '/classify/:id' => 'workflows#classify'
  match '/next_task_or_end/:id' => 'workflows#next_task_or_end'
  match '/add_favourites' => 'workflows#add_favourites', :as => :add_favourite
  match '/rewind/:id' => 'workflows#rewind'
  match '/logout' => 'application#cas_logout'
  
  match '/profile' => 'home#profile', :as => :profile
  match '/toggle_api' => 'home#toggle_api'
  root :to => 'home#index'
end
