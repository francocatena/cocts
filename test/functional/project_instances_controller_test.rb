require 'test_helper'

class ProjectInstancesControllerTest < ActionController::TestCase
  fixtures :question_instances, :answer_instances, :projects
  
  setup do
    @project_instance = ProjectInstance.find(project_instances(:one).id)
  end

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    id_param = {:id => @project_instance.to_param}
    identifier_project = {:identifier => projects(:manual).to_param}
    id_project = {:id => projects(:manual).to_param}
    public_actions = [
      [:post, :create],
      [:get, :new, identifier_project]      
    ]
    private_actions = [
      [:get, :index, id_project],
      [:get, :show, id_param],     
      [:get, :edit, id_param],
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
  
  test 'list project instances' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:project_instances)
    #assert_select '#error_body', false
    assert_template 'project_instances/index'
  end
  
  test 'show project instance' do
    perform_auth
    get :show, :id => @project_instance.to_param
    assert_response :success
    assert_not_nil assigns(:project_instance)
    assert_select '#error_body', false
    assert_template 'project_instances/show'
  end
 
  test 'new project instance' do
    get :new, :identifier => @project_instance.to_param
    assert_response :success
    assert_not_nil assigns(:project_instance)
    assert_template 'project_instances/new'
  end

  test 'create project instance' do
    perform_auth
    @request.host = 'admin.cocts.com'
    assert_difference 'ProjectInstance.count' do
      post :create, {
        :project_instance => {
          :first_name => 'Firstname',
          :last_name => 'Lastname',
          :email => 'test@cirope.com.ar',
          :question_instance_ids => [question_instances(:one).id],
          :project_id => projects(:manual).id
        }
      }
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project_instance)
    assert_equal 'Firstname', assigns(:project_instance).first_name
  end


  test 'edit project instance' do
    perform_auth
    get :edit, :id => @project_instance.to_param
    assert_response :success
    assert_not_nil assigns(:project_instance)
    assert_select '#error_body', false
    assert_template 'project_instances/edit'
  end

  test 'update project instance' do
    perform_auth
    assert_no_difference 'ProjectInstance.count' do
      assert_difference '@project_instance.reload.question_instances.size' do
        put :update, {
          :id => @project_instance.to_param,
          :project_instance => {
            :first_name => 'Updated firstname',
            :last_name => 'Updated lastname',
            :email => 'updated@cirope.com.ar',
            :question_instance_ids => [question_instances(:one).id], 
             # question_instances(:two).id],
            :project_id => projects(:manual).id
          }
        }
      end
    end

    assert_redirected_to project_instance_path
    assert_not_nil assigns(:project_instance)
    assert_equal 'Updated firstname', assigns(:project_instance).first_name
    assert_equal 'updated@cirope.com.ar', assigns(:project_instance).email
    
  end
  
  test 'destroy project instance' do
    perform_auth
    id_project = @project_instance.project_id
    assert_difference('ProjectInstance.count', -1) do
      delete :destroy, :id => @project_instance.to_param
    end

    assert_redirected_to project_instances_url(:id => id_project)
  end
end
