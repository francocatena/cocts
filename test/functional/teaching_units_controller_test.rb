# encoding: UTF-8

require 'test_helper'

class TeachingUnitsControllerTest < ActionController::TestCase
  fixtures :teaching_units, :questions

  # Inicializa de forma correcta todas las variables que se utilizan en las
  # pruebas
  def setup
    @teaching_unit = TeachingUnit.find(teaching_units(:udI).id)
  end
  
  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    id_param = {:id => @teaching_unit.to_param}
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
  
  test 'list teaching_units' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_units)
    assert_select '#error_body', false
    assert_template 'teaching_units/index'
  end
  
  test 'show teaching_unit' do
    perform_auth
    get :show, :id => @teaching_unit.to_param
    assert_response :success
    assert_not_nil assigns(:teaching_unit)
    assert_select '#error_body', false
    assert_template 'teaching_units/show'
  end

  test 'new teaching_unit' do
    perform_auth
    get :new
    assert_response :success
    assert_not_nil assigns(:teaching_unit)
    assert_select '#error_body', false
    assert_template 'teaching_units/new'
  end
  
  test 'create teaching_unit' do
    perform_auth
    assert_difference ['TeachingUnit.count'] do
      post :create, {
        :teaching_unit => {
          :title => 'Enseñanza en la sociedad',
          :question_ids => [questions(:q10111).id]
        }
      }
    end

    assert_redirected_to teaching_units_path
    assert_not_nil assigns(:teaching_unit)
  end
  
  test 'edit teaching_unit' do
    perform_auth
    get :edit, :id => @teaching_unit.to_param
    assert_response :success
    assert_not_nil assigns(:teaching_unit)
    assert_select '#error_body', false
  end
  
  test 'update teaching_unit' do
    perform_auth
    assert_no_difference'TeachingUnit.count' do
      put :update, {
          :id => @teaching_unit.to_param,
          :teaching_unit => {
            :title => 'Ciencias',
            :question_ids => [questions(:q10111).id]
          }
        }
      end
    
    assert_redirected_to teaching_units_path
    assert_not_nil assigns(:teaching_unit)
  end
  
  test 'destroy teaching_unit' do
    perform_auth
    assert_difference('TeachingUnit.count', -1) do
      delete :destroy, :id => @teaching_unit.to_param
    end

    assert_redirected_to teaching_units_path
  end
end
