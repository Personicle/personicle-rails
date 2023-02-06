Rails.application.routes.draw do
  
  get 'mobility/index'
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
  get 'home/index'
  
  # devise_for :users
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  get '/logout', :to => 'sessions#destroy'
  get '/login', :to => 'sessions#new', :as => :login
  resources :users
  root to: 'pages#login'
  get 'pages/dashboard', :to => 'dashboard#index'
  get 'pages/dashboard/physician', :to =>'physician#index'
  # post 'pages/physician-create-account', :to =>'physician#create_account'
  post 'pages/dashboard', :to => 'dashboard#index'
  get 'pages/connections', :to => 'connection#index'
  get 'pages/profile', :to => 'profile#index'
  post 'pages/profile/add_physician', :to=>'profile#add_physician'
  post 'pages/profile/update_user_info', :to=>'profile#update_user_info'
  # post 'pages/profile', :to => 'profile#index'
  get 'pages/foodlog', :to => 'foodlog#index'
  get 'pages/foodlog/data', :to => 'foodlog#get_edamam_data' , :as => 'get_edamam_data' 
  post 'pages/foodlog/log', :to => 'foodlog#log_food', :as => 'log_food'
  get 'pages/mobility', :to => 'mobility#index'
  post 'pages/mobility', :to => 'mobility#index'
  get 'pages/sleep', :to => 'sleep#index'
  post 'pages/sleep', :to => 'sleep#index'
  # get 'pages/foodlog/recipes', :to => 'foodlog#render'
  get 'pages/login'
  post 'pages/create-physician-account', :to => 'pages#create_physician_account'
  # get 'pages/register'
  # get 'pages/recipes'
  get 'pages/dashboard/physician-questions', :to=> 'user_questions#index'
  post 'pages/dashboard/physician-questions', :to=> 'user_questions#send_responses'
  post 'pages/profile/remove_physician', :to=>'profile#remove_physician'
  post 'pages/dashboard/physician/get_user_data',  :to =>'physician#get_user_data'
  get  'pages/dashboard/physician/get_user_data',  :to =>'physician#get_user_data'
  post 'question/create', :to => 'question#create'
  post 'question/delete', :to => 'question#delete_questions'
  get  'image/upload', :to => 'image#upload'
  post 'image/send_packet', :to => 'image#send_packet', :as => 'send_packet'
  post 'pages/dashboard/delete-event', :to => 'dashboard#delete_event', :as => 'delete_user_events'
  post 'pages/dashboard/update-event', :to => 'dashboard#update_event', :as => 'update_user_events'

  get 'pages/exposome', :to => 'exposome#index'
  post 'pages/exposome', :to => 'exposome#index'
  get 'pages/exposome/get_exposome_data', :to => 'exposome#get_exposome_data', :as => 'get_exposome_data'

  get 'pages/user/create_question', :to => 'create_user_questions#index'
  post 'pages/user/create_question', :to => 'create_user_questions#create'
  post 'pages/user/send_responses', :to => 'create_user_questions#send_responses'
  get 'pages/user/responses', :to => 'user_responses#index'
  post 'pages/user/responses', :to => 'user_responses#index'

  get 'pages/dashboard', to: 'dashboard#geocode'

  get 'pages/analysis', :to => 'analysis#index', :as => 'analysis_page'
  post 'pages/analysis', :to => 'analysis#index'

  get 'pages/analysis/new_analysis', :to => 'analysis#add_analysis'
  post 'pages/analysis/new_analysis', :to => 'analysis#add_analysis', :as => 'add_analysis'

  post 'pages/analysis/select-analysis', :to => 'analysis#select_analysis', :as => 'select_user_analysis'
  post 'pages/analysis/delete-analysis', :to => 'analysis#delete_analysis', :as => 'delete_user_analysis'
end

