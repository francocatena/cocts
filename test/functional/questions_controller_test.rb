require 'test_helper'

# Pruebas para el controlador de cuestiones
class QuestionsControllerTest < ActionController::TestCase
  fixtures :questions, :answers

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

  test 'list questions' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:questions)
    assert_select '#error_body', false
    assert_template 'questions/index'
  end

  test 'show question' do
    perform_auth
    get :show, :id => questions(:_10111)
    assert_response :success
    assert_not_nil assigns(:question)
    assert_select '#error_body', false
    assert_template 'questions/show'
  end

  test 'new question' do
    perform_auth
    get :new
    assert_response :success
    assert_not_nil assigns(:question)
    assert_select '#error_body', false
    assert_template 'questions/new'
  end

  test 'create question' do
    perform_auth
    assert_difference ['Question.count', 'Answer.count'] do
      post :create, {
        :question => {
          :dimension => Question::DIMENSIONS.first,
          :code => '10211',
          :question => 'Definir qué es la tecnología puede resultar difícil ' +
            'porque ésta sirve para muchas cosas. Pero la tecnología ' +
            'PRINCIPALMENTE es:',
          :answers_attributes => {
            :new_1 => {
              :category => Answer::CATEGORIES[:plausible],
              :order => 1,
              :clarification => 'New clarification',
              :answer => 'New answer'
            }
          }
        }
      }
    end

    assert_redirected_to questions_path
    assert_not_nil assigns(:question)
    assert_equal '10211', assigns(:question).code
    assert_equal 'New answer', assigns(:question).answers.first.answer
  end

  test 'edit question' do
    perform_auth
    get :edit, :id => questions(:_10111)
    assert_response :success
    assert_not_nil assigns(:question)
    assert_select '#error_body', false
    assert_template 'questions/edit'
  end

  test 'update question' do
    perform_auth
    assert_no_difference'Question.count' do
      assert_difference 'Answer.count' do
        put :update, {
          :id => questions(:_10111),
          :question => {
            :dimension => Question::DIMENSIONS.first,
            :code => '10211',
            :question => 'Definir qué es la tecnología puede resultar difícil ' +
              'porque ésta sirve para muchas cosas. Pero la tecnología ' +
              'PRINCIPALMENTE es:',
            :answers_attributes => {
              :new_1 => {
                :category => Answer::CATEGORIES[:plausible],
                :order => 1,
                :clarification => 'New clarification',
                :answer => 'New answer'
              },
              answers(:'10111_1').id => {
                :id => answers(:'10111_1').id,
                :category => Answer::CATEGORIES[:plausible],
                :order => 2,
                :clarification => 'Updated clarification 1',
                :answer => 'Updated answer 1'
              },
              answers(:'10111_2').id => {
                :id => answers(:'10111_2').id,
                :category => Answer::CATEGORIES[:adecuate],
                :order => 3,
                :clarification => 'Updated clarification 2',
                :answer => 'Updated answer 2'
              }
            }
          }
        }
      end
    end

    assert_redirected_to questions_path
    assert_not_nil assigns(:question)
    assert_equal '10211', assigns(:question).code
    assert_equal 'Updated clarification 2',
      Answer.find(answers(:'10111_2').id).clarification
  end

  test 'destroy question' do
    perform_auth
    assert_difference('Question.count', -1) do
      delete :destroy, :id => questions(:_10111)
    end

    assert_redirected_to questions_path
  end
end