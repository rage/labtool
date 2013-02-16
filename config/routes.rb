Labtool::Application.routes.draw do
  resources :peer_reviews
  resources :week_feedbacks
  resources :registrations
  resources :courses
  resources :users
  match 'register' => 'registrations#new'

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"

  resources :sessions

  match 'courses/:id/activity' => 'courses#activity', :via => :post

  match 'mypage' => 'mypage#index', :via => :get
  match 'mypage' => 'mypage#redirect', :via => :post
  match 'mypage/:student_number' => 'mypage#show',  :via => :get
  match 'mypage/:student_number' => 'mypage#edit',  :via => :post
  match 'mypage/:student_number' => 'mypage#update',  :via => :put

  match 'foobar' => 'mypage#foobar'
  match 'toggle_review' => 'peer_reviews#toggle_review'
  match 'complete_review' => 'peer_reviews#complete_review'

  match 'toggle_review_participation' => 'registrations#toggle_participation'

  root :to => 'mypage#index'
end
