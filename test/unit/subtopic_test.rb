require 'test_helper'

class SubtopicTest < ActiveSupport::TestCase
   fixtures :subtopics
  
  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @subtopic = Subtopic.find subtopics(:subtopicI).id
  end
  
  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of Subtopic, @subtopic
    assert_equal subtopics(:subtopicI).title, @subtopic.title
    assert_equal subtopics(:subtopicI).code, @subtopic.code
  end
  
  # Prueba la creación de un subtema
  test 'create' do
    assert_difference 'Subtopic.count' do
      @subtopic = Subtopic.create(
        title: 'Ciencia en la escuela',
        code: '009'
      )
    end
  end
  
  # Prueba de actualización de un subtema
  test 'update' do
    assert_no_difference 'Subtopic.count' do
      assert @subtopic.update_attributes(code: 0001, title: 'Updated title'),
        @subtopic.errors.full_messages.join('; ')
    end

    @subtopic.reload
    assert_equal 0001, @subtopic.code
    assert_equal 'Updated title', @subtopic.title
  end
  
  # Prueba de eliminación de subtemas
  test 'delete' do
    assert_difference('Subtopic.count', -1) { @subtopic.destroy }
  end
  
  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @subtopic.code = '   '
    @subtopic.title = '   '
    assert @subtopic.invalid?
    assert_equal 2, @subtopic.errors.count
    assert_equal [error_message_from_model(@subtopic, :code, :blank)],
      @subtopic.errors[:code]
    assert_equal [error_message_from_model(@subtopic, :title, :blank)],
      @subtopic.errors[:title]
  
  end
  
  test 'validates formated attributes' do
    @subtopic.code = '1abc1'
    assert @subtopic.invalid?
    assert_equal 1, @subtopic.errors.count
    assert_equal [error_message_from_model(@subtopic, :code, :not_a_number)],
      @subtopic.errors[:code]
  end
end
