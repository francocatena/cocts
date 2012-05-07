# -*- coding: utf-8 -*-
require 'test_helper'

# Pruebas para el controlador de proyectos
class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects, :questions

  def setup
    @project = Project.find(projects(:manual).id)
  end

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    id_param = {:id => @project.to_param}
    public_actions = []
    private_actions = [
      [:get, :index],
      [:get, :show, id_param],
      [:get, :new],
      [:get, :edit, id_param],
      [:post, :create],
      [:put, :update, id_param],
      [:delete, :destroy, id_param]
    ]

    private_actions.each do |action|
      send *action
      assert_redirected_to login_users_path
      assert_equal I18n.t(:'messages.must_be_authenticated'), flash[:notice]
    end

    public_actions.each do |action|
      send *action
      assert_response :success
    end
  end

  test 'list projects' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
    assert_select '#error_body', false
    assert_template 'projects/index'
  end

  test 'show project' do
    perform_auth
    get :show, :id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:project)
    assert_template 'projects/show'
  end

  test 'show project in pdf' do
    perform_auth
    get :show, :id => @project.to_param, :format => 'pdf'
    assert_redirected_to "/#{@project.pdf_relative_path}"
    assert_not_nil assigns(:project)
    assert_select '#error_body', false
  end

  test 'new project' do
    perform_auth
    get :new
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select '#error_body', false
    assert_template 'projects/new'
  end

  test 'create project' do
    perform_auth
    assert_difference 'Project.count' do
      post :create, {
        :project => {
          :name => 'New name',
          :identifier => 'new-project',
          :description => 'New description',
          :group_name => 'New Group',
          :group_type => 'Group type',
          :test_type => 'Pre-test',
          :year => Date.today.year,
          :project_type => Project::TYPES[:manual],
          :valid_until => 1.month.from_now.to_date,
          :forms => [
            Project::SOCIODEMOGRAPHIC_FORMS.first,
            Project::SOCIODEMOGRAPHIC_FORMS.last
          ],
          :question_ids => [questions(:_10111).id]
        }
      }
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project)
    assert_equal 'New name', assigns(:project).name
    assert_equal 2, assigns(:project).forms.size
  end

  test 'edit project' do
    perform_auth
    get :edit, :id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select '#error_body', false
    assert_template 'projects/edit'
  end

  test 'update project' do
    perform_auth

    assert_no_difference 'Project.count' do
      assert_difference '@project.reload.questions.size' do
        put :update, {
          :id => @project.to_param,
          :project => {
            :name => 'Updated name',
            :identifier => 'updated-identifier',
            :description => 'Updated description',
            :year => Date.today.year,
            :project_type => Project::TYPES[:manual],
            :valid_until => 1.month.from_now.to_date,
            :forms => [
              Project::SOCIODEMOGRAPHIC_FORMS.first,
              Project::SOCIODEMOGRAPHIC_FORMS.last
            ],
            :question_ids => [questions(:_10111).id, questions(:_10113).id]
          }
        }
      end
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project)
    assert_equal 'Updated name', assigns(:project).name
    assert_equal 2, assigns(:project).forms.size
  end

  test 'destroy project' do
    perform_auth
    assert_no_difference('Project.count') do
      delete :destroy, :id => @project.to_param
    end
    @project.project_instances.clear
    assert_difference('Project.count', -1) do
      delete :destroy, :id => @project.to_param
    end

    assert_redirected_to projects_path
  end

  test 'preview sociodemographic form' do
    perform_auth
    get :preview_form
    assert_response :success
  end

  test 'autocomplete for question' do
    perform_auth
    get :autocomplete_for_question, { :q => '10111', :format => :json }
    assert_response :success
    
    questions = ActiveSupport::JSON.decode(@response.body)
    
    assert_equal 1, questions.size
    assert questions.all? { |q| ("#{q['label']} #{q['informal']}").match /10111/i }

    get :autocomplete_for_question, { :q => 'ciencia', :format => :json }
    assert_response :success
    
    questions = ActiveSupport::JSON.decode(@response.body)
    
    assert_equal 2, questions.size
    assert questions.all? { |q| ("#{q['label']} #{q['informal']}").match /ciencia/i }

    get :autocomplete_for_question, { :q => 'xyz', :format => :json }
    assert_response :success
    
    questions = ActiveSupport::JSON.decode(@response.body)
    
    assert questions.empty?
  end
end
