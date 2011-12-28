require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  fixtures :topics

  # Inicializa de forma correcta todas las variables que se utilizan en las
  # pruebas
  def setup
    @topic = Topic.find(topics(:topicI).id)
  end
  
  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    id_param = {:id => @topic.to_param}
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
  
  test 'list topics' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:topics)
    assert_select '#error_body', false
    assert_template 'topics/index'
  end
  
  test 'show topic' do
    perform_auth
    get :show, :id => @topic.to_param
    assert_response :success
    assert_not_nil assigns(:topic)
    assert_select '#error_body', false
    assert_template 'topics/show'
  end

  test 'new topic' do
    perform_auth
    get :new
    assert_response :success
    assert_not_nil assigns(:topic)
    assert_select '#error_body', false
    assert_template 'topics/new'
  end
  
  test 'create topic' do
    perform_auth
    assert_difference ['Topic.count'] do
      post :create, {
        :topic => {
          :title => 'Ciencia y Sociedad',
          :code => 033
        }
      }
    end

    assert_redirected_to topics_path
    assert_not_nil assigns(:topic)
    assert_equal 033, assigns(:topic).code
  end
  
  test 'edit topic' do
    perform_auth
    get :edit, :id => @topic.to_param
    assert_response :success
    assert_not_nil assigns(:topic)
    assert_select '#error_body', false
    assert_template 'topics/edit'
  end
  
  test 'update topic' do
    perform_auth
    assert_no_difference'Topic.count' do
      put :update, {
          :id => @topic.to_param,
          :topic => {
            :code => 10211,
            :title => 'Ciencias sociales'
          }
        }
      end
    
    assert_redirected_to topic_path
    assert_not_nil assigns(:topic)
    assert_equal 10211, assigns(:topic).code
  end
  
  test 'destroy topic' do
    perform_auth
    assert_difference('Topic.count', -1) do
      delete :destroy, :id => @topic.to_param
    end

    assert_redirected_to topics_path
  end
     
end
