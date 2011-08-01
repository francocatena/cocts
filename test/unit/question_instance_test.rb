require 'test_helper'

class QuestionInstanceTest < ActiveSupport::TestCase
  fixtures :question_instances
  
  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @question_instance = QuestionInstance.find question_instances(:one).id
  end
  
  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of QuestionInstance, @question_instance
    assert_equal question_instances(:one).question_text, 
      @question_instance.question_text
  end
  
  # Prueba la creación de una instancia de cuestión
  test 'create' do
    assert_difference 'QuestionInstance.count' do
      @question_instance = QuestionInstance.create(
        :question_text => 'Definir qué es la tecnología puede resultar difícil ' +
          'porque ésta sirve para muchas cosas. Pero la tecnología ' +
          'PRINCIPALMENTE es:',
        :answer_instances => [answer_instances(:one)]
      )
    end
  end

  # Prueba de actualización de una cuestión
  test 'update' do
    assert_no_difference 'QuestionInstance.count' do
      assert @question_instance.update_attributes(:question_text => 'Question text'),
        @question_instance.errors.full_messages.join('; ')
    end

    @question_instance.reload
    assert_equal 'Question text', @question_instance.question_text
  end

  # Prueba de eliminación de instancias de cuestiones
  test 'delete' do
    assert_difference('QuestionInstance.count', -1) { @question_instance.destroy }
  end
  
end
