CoctsApp::Application.routes.draw do

  resources :teaching_units

  resources :subtopics do
    collection do
      get :autocomplete_for_teaching_unit
    end
  end

  resources :topics do
    collection do
      get :autocomplete_for_subtopic
    end
  end

  resources :question_instances

  resources :answer_instances

  resources :project_instances

  resources :questions do
    collection do
      post :csv_import_questions
      post :csv_import_answers
      get :import_csv
    end
  end

  resources :projects do
    collection do
      get :autocomplete_for_question
      get :preview_form
      get :select_new
    end
    member do
      get :pdf_rates
    end
  end

  resources :users do
    collection do
      get :login
      post :create_session
    end

    member do
      get :logout
      get :edit_password
      patch :update_password
      get :edit_personal_data
      patch :update_personal_data
    end
  end

  root 'project_instances#new', constraints: { subdomain: /\d+-[[:alpha:]]-[[:alpha:]]{3}/ }

  root 'users#login', contrainsts: {subdomain: 'admin'}, as: :authenticated_user
end
