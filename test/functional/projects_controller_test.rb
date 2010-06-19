require 'test_helper'

# Pruebas para el controlador de proyectos
class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    public_actions = []
    private_actions = [:index, :show, :new, :edit, :create, :update, :destroy]

    private_actions.each do |action|
      get action
      assert_redirected_to login_users_path
      assert_equal I18n.t(:'messages.must_be_authenticated'), flash[:notice]
    end

    public_actions.each do |action|
      get action
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
    get :show, :id => projects(:manual).to_param
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select '#error_body', false
    assert_template 'projects/show'
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
          :year => Date.today.year,
          :project_type => Project::TYPES[:manual],
          :valid_until => 1.month.from_now.to_date,
          :forms => [
            Project::SOCIODEMOGRAPHIC_FORMS.first,
            Project::SOCIODEMOGRAPHIC_FORMS.last
          ]
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
    get :edit, :id => projects(:manual).to_param
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select '#error_body', false
    assert_template 'projects/edit'
  end

  test 'update project' do
    perform_auth
    assert_no_difference 'Project.count' do
      put :update, {
        :id => projects(:manual).to_param,
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
          ]
        }
      }
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project)
    assert_equal 'Updated name', assigns(:project).name
    assert_equal 2, assigns(:project).forms.size
  end

  test 'destroy project' do
    perform_auth
    assert_difference('Project.count', -1) do
      delete :destroy, :id => projects(:manual).to_param
    end

    assert_redirected_to projects_path
  end
end