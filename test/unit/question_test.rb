# -*- coding: utf-8 -*-
require 'test_helper'

# Clase para probar el modelo "Question"
class QuestionTest < ActiveSupport::TestCase
  fixtures :questions

  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @question = Question.find questions(:_10111).id
  end

  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of Question, @question
    assert_equal questions(:_10111).dimension, @question.dimension
    assert_equal questions(:_10111).code, @question.code
    assert_equal questions(:_10111).question, @question.question
  end

  # Prueba la creación de una cuestión
  test 'create' do
    assert_difference 'Question.count' do
      @question = Question.create(
        :dimension => Question::DIMENSIONS.first,
        :code => '10211',
        :question => 'Definir qué es la tecnología puede resultar difícil ' +
          'porque ésta sirve para muchas cosas. Pero la tecnología ' +
          'PRINCIPALMENTE es:'
      )
    end
  end

  # Prueba de actualización de una cuestión
  test 'update' do
    assert_no_difference 'Question.count' do
      assert @question.update_attributes(:code => '10212'),
        @question.errors.full_messages.join('; ')
    end

    @question.reload
    assert_equal '10212', @question.code
  end

  # Prueba de eliminación de cuestiones
  test 'delete' do
    assert_no_difference('Question.count') { @question.destroy }
    @question.projects.clear
    assert_difference('Question.count', -1) { @question.destroy }
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @question.code = '   '
    @question.question = '   '
    @question.dimension = nil
    assert @question.invalid?
    assert_equal 3, @question.errors.count
    assert_equal [error_message_from_model(@question, :code, :blank)],
      @question.errors[:code]
    assert_equal [error_message_from_model(@question, :question, :blank)],
      @question.errors[:question]
    assert_equal [error_message_from_model(@question, :dimension, :blank)],
      @question.errors[:dimension]
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates unique attributes' do
    @question.code = questions(:_10113).code
    assert @question.invalid?
    assert_equal 1, @question.errors.count
    assert_equal [error_message_from_model(@question, :code, :taken)],
      @question.errors[:code]
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates formated attributes' do
    @question.code = '1abc1'
    @question.dimension = '1_'
    assert @question.invalid?
    assert_equal 2, @question.errors.count
    assert_equal [error_message_from_model(@question, :code, :invalid)],
      @question.errors[:code]
    assert_equal [error_message_from_model(@question, :dimension, :not_a_number)],
      @question.errors[:dimension]
  end

  test 'validates lenght attributes' do
    @question.code = '10001' * 52
    assert @question.invalid?
    assert_equal [error_message_from_model(@question, :code, :too_long,
      :count => 255)], @question.errors[:code]
  end

  test 'validates included attributes' do
    @question.dimension = Question::DIMENSIONS.last.next
    assert @question.invalid?
    assert_equal 1, @question.errors.count
    assert_equal [error_message_from_model(@question, :dimension, :inclusion)],
      @question.errors[:dimension]
  end

end
