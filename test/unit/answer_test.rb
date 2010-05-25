require 'test_helper'

# Clase para probar el modelo "Answer"
class AnswerTest < ActiveSupport::TestCase
  fixtures :answers

  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @answer = Answer.find answers(:'10111_1').id
  end

  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of Answer, @answer
    assert_equal answers(:'10111_1').category, @answer.category
    assert_equal answers(:'10111_1').order, @answer.order
    assert_equal answers(:'10111_1').clarification, @answer.clarification
    assert_equal answers(:'10111_1').answer, @answer.answer
    assert_equal answers(:'10111_1').question_id, @answer.question_id
  end

  # Prueba la creación de una respuesta
  test 'create' do
    assert_difference 'Answer.count' do
      @answer = Answer.create(
        :question => questions(:_10111),
        :category => Answer::CATEGORIES[:plausible],
        :order => 1,
        :clarification => 'New clarification',
        :answer => 'New answer'
      )
    end
  end

  # Prueba de actualización de una respuesta
  test 'update' do
    assert_no_difference 'Answer.count' do
      assert @answer.update_attributes(:answer => 'Updated answer'),
        @answer.errors.full_messages.join('; ')
    end

    @answer.reload
    assert_equal 'Updated answer', @answer.answer
  end

  # Prueba de eliminación de respuestas
  test 'delete' do
    assert_difference('Answer.count', -1) { @answer.destroy }
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @answer.answer = '   '
    @answer.category = '   '
    @answer.order = nil
    assert @answer.invalid?
    assert_equal 3, @answer.errors.count
    assert_equal error_message_from_model(@answer, :answer, :blank),
      @answer.errors.on(:answer)
    assert_equal error_message_from_model(@answer, :category, :blank),
      @answer.errors.on(:category)
    assert_equal error_message_from_model(@answer, :order, :blank),
      @answer.errors.on(:order)
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates formated attributes' do
    @answer.category = '1.2'
    @answer.order = '?1'
    assert @answer.invalid?
    assert_equal 2, @answer.errors.count
    assert_equal error_message_from_model(@answer, :category, :not_a_number),
      @answer.errors.on(:category)
    assert_equal error_message_from_model(@answer, :order, :not_a_number),
      @answer.errors.on(:order)
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates included attributes' do
    @answer.category = Answer::CATEGORIES.values.sort.last.next
    assert @answer.invalid?
    assert_equal 1, @answer.errors.count
    assert_equal error_message_from_model(@answer, :category, :inclusion),
      @answer.errors.on(:category)
  end
end