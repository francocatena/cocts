require 'test_helper'

class AnswerInstanceTest < ActiveSupport::TestCase
  fixtures :answer_instances
  
  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @answer_instance = AnswerInstance.find answer_instances(:one).id
  end
  
  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of AnswerInstance, @answer_instance
    assert_equal answer_instances(:one).answer_category, @answer_instance.answer_category
    assert_equal answer_instances(:one).answer_text, @answer_instance.answer_text
    assert_equal answer_instances(:one).valuation, @answer_instance.valuation
    assert_equal answer_instances(:one).answer_id, @answer_instance.answer_id
    assert_equal answer_instances(:one).question_instance_id, @answer_instance.question_instance_id
  end
  
  # Prueba la creación de una instancia de respuesta
  test 'create' do
    assert_difference 'AnswerInstance.count' do
      @answer_instance = AnswerInstance.create(
        :answer => answers(:'10111_1'),
        :answer_category => answers(:'10111_1').category,
        :answer_text => answers(:'10111_1').answer,
        :valuation => '5',
        :question_instance => question_instances(:one),
        :order => '4'
    )
    end
  end
  
  # Prueba de actualización de una instancia de respuesta
  test 'update' do
    assert_no_difference 'AnswerInstance.count' do
      assert @answer_instance.update_attributes(:answer_text => 'Updated answer instance',
        :valuation => '2', :answer_category => AnswerInstance::CATEGORIES[:adecuate]),
        @answer_instance.errors.full_messages.join('; ')
    end

    @answer_instance.reload
    assert_equal 'Updated answer instance', @answer_instance.answer_text
    assert_equal '2', @answer_instance.valuation
    assert_equal AnswerInstance::CATEGORIES[:adecuate], @answer_instance.answer_category
  end

  # Prueba de eliminación de instancias de respuestas
  test 'delete' do
    assert_difference('AnswerInstance.count', -1) { @answer_instance.destroy }
  end
  
  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @answer_instance.answer_text = '   '
    @answer_instance.answer_category = '   '
    @answer_instance.valuation = '   ' 
    assert @answer_instance.invalid?
    assert_equal 3, @answer_instance.errors.count
    assert_equal [error_message_from_model(@answer_instance, :answer_text, :blank)],
      @answer_instance.errors[:answer_text]
    assert_equal [error_message_from_model(@answer_instance, :answer_category, :blank)],
      @answer_instance.errors[:answer_category]
    assert_equal [error_message_from_model(@answer_instance, :valuation, :blank)],
      @answer_instance.errors[:valuation]
  end
  
  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates formated attributes' do
    @answer_instance.answer_category = '1.2'
    @answer_instance.valuation = '?1'
    assert @answer_instance.invalid?
    assert_equal 2, @answer_instance.errors.count
    assert_equal [error_message_from_model(@answer_instance, :answer_category,
        :not_an_integer)], @answer_instance.errors[:answer_category]
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates included attributes' do
    @answer_instance.answer_category = Answer::CATEGORIES.values.sort.last.next
    assert @answer_instance.invalid?
    assert_equal 1, @answer_instance.errors.count
    assert_equal [error_message_from_model(@answer_instance, :answer_category, :inclusion)],
      @answer_instance.errors[:answer_category]
  end
  
end
