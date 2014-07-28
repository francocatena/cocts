# -*- coding: utf-8 -*-
require 'test_helper'

class SubtopicsControllerTest < ActionController::TestCase
  fixtures :topics

  # Inicializa de forma correcta todas las variables que se utilizan en las
  # pruebas
  def setup
    @subtopic = Subtopic.find(subtopics(:subtopicI).id)
  end

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    id_param = {id: @subtopic.to_param}
    public_actions = []
    private_actions = [
      [:get, :index],
      [:get, :show, id_param],
      [:get, :new],
      [:get, :edit, id_param],
      [:post, :create],
      [:put, :update, id_param],
      [:delete, :destroy, id_param],
      [:get, :autocomplete_for_teaching_unit]
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

  test 'list subtopics' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:subtopics)
    assert_select '#error_body', false
    assert_template 'subtopics/index'
  end

  test 'show subtopic' do
    perform_auth
    get :show, id: @subtopic.to_param
    assert_response :success
    assert_not_nil assigns(:subtopic)
    assert_select '#error_body', false
    assert_template 'subtopics/show'
  end

  test 'new subtopic' do
    perform_auth
    get :new
    assert_response :success
    assert_not_nil assigns(:subtopic)
    assert_select '#error_body', false
    assert_template 'subtopics/new'
  end

  test 'create subtopic' do
    perform_auth
    assert_difference ['Subtopic.count'] do
      post :create, {
        subtopic: {
          title: 'Las mujeres y la ciencia',
          code: 001,
          teaching_unit_ids: [teaching_units(:udII).id]
        }
      }
    end

    assert_redirected_to subtopics_path
    assert_not_nil assigns(:subtopic)
    assert_equal 001, assigns(:subtopic).code
  end

  test 'edit subtopic' do
    perform_auth
    get :edit, id: @subtopic.to_param
    assert_response :success
    assert_not_nil assigns(:subtopic)
    assert_select '#error_body', false
    assert_template 'subtopics/edit'
  end

  test 'update subtopic' do
    perform_auth
    assert_no_difference'Subtopic.count' do
      put :update, {
          id: @subtopic.to_param,
          subtopic: {
            code: 10211,
            title: 'Ciencias sociales'
          }
        }
      end

    assert_redirected_to subtopic_path
    assert_not_nil assigns(:subtopic)
    assert_equal 10211, assigns(:subtopic).code
  end

  test 'destroy subtopic' do
    perform_auth
    assert_difference('Subtopic.count', -1) do
      delete :destroy, id: @subtopic.to_param
    end

    assert_redirected_to subtopics_path
  end

  test 'autocomplete for teaching_unit' do
    perform_auth
    get :autocomplete_for_teaching_unit, { q: 'UD II', format: :json }
    assert_response :success

    teaching_units = ActiveSupport::JSON.decode(@response.body)

    assert_equal 1, teaching_units.size
    assert teaching_units.all? { |q| ("#{q['label']}").match /UD I/i }

    get :autocomplete_for_teaching_unit, { q: 'ud', format: :json }
    assert_response :success

    teaching_units = ActiveSupport::JSON.decode(@response.body)

    assert_equal 2, teaching_units.size
    assert questions.all? { |q| ("#{q['label']}").match /ud/i }

    get :autocomplete_for_teaching_unit, { q: 'xyz', format: :json }
    assert_response :success

    teaching_units = ActiveSupport::JSON.decode(@response.body)

    assert teaching_units.empty?
  end

end
