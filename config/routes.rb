Rails.application.routes.draw do
  resources :quizzes do
    resources :messages, only: [:create]
  end
  root "quizzes#index"

  post "/insert_quiz", to: "quizzes#create"
  # get "/quizzes/:id", to: "quizzes#show", as: "quiz"

end
