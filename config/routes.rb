Labtool::Application.routes.draw do
  resources :registrations
  resources :courses
  resources :users
  match 'register' => 'registrations#new'

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"

  resources :sessions

  match 'mypage' => 'mypage#index', :via => :get
  match 'mypage' => 'mypage#redirect', :via => :post
  match 'mypage/:student_number' => 'mypage#show',  :via => :get
  match 'mypage/:student_number' => 'mypage#edit',  :via => :post
  match 'mypage/:student_number' => 'mypage#update',  :via => :put

  root :to => 'mypage#index'
end
