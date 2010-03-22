require 'test_helper'

# Pruebas para el controlador de proyectos
class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects

  # Inicializa de forma correcta todas las variables que se utilizan en las
  # pruebas
  def setup
    @public_actions = []
    @private_actions = [:index, :show, :new, :edit, :create, :update, :destroy]
  end

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    @private_actions.each do |action|
      get action
      assert_redirected_to login_users_path
      assert_equal I18n.t(:'messages.must_be_authenticated'), flash[:notice]
    end

    @public_actions.each do |action|
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
    get :show, :id => projects(:manual)
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
          :description => 'New description',
          :year => Date.today.year,
          :project_type => Project::TYPES[:manual],
          :valid_until => 1.month.from_now.to_date
        }
      }
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project)
    assert_equal 'New name', assigns(:project).name
  end

  test 'edit project' do
    perform_auth
    get :edit, :id => projects(:manual)
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select '#error_body', false
    assert_template 'projects/edit'
  end

  test 'update project' do
    perform_auth
    assert_no_difference 'Project.count' do
      put :update, {
        :id => projects(:manual),
        :project => {
          :name => 'Updated name',
          :description => 'Updated description',
          :year => Date.today.year,
          :project_type => Project::TYPES[:manual],
          :valid_until => 1.month.from_now.to_date
        }
      }
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project)
    assert_equal 'Updated name', assigns(:project).name
  end

  test 'destroy project' do
    perform_auth
    assert_difference('Project.count', -1) do
      delete :destroy, :id => projects(:manual)
    end

    assert_redirected_to projects_path
  end
end