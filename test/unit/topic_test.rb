require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics
  
  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @topic = Topic.find topics(:topicI).id
  end
  
  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of Topic, @topic
    assert_equal topics(:topicI).title, @topic.title
    assert_equal topics(:topicI).code, @topic.code
  end
  
  # Prueba la creación de un tema
  test 'create' do
    assert_difference 'Topic.count' do
      @topic = Topic.create(
        :title => 'Ciencia y Sociedad',
        :code => '1009'
      )
    end
  end
  
  # Prueba de actualización de un tema
  test 'update' do
    assert_no_difference 'Topic.count' do
      assert @topic.update_attributes(:code => 0001, :title => 'Updated title'),
        @topic.errors.full_messages.join('; ')
    end

    @topic.reload
    assert_equal 0001, @topic.code
    assert_equal 'Updated title', @topic.title
  end
  
  # Prueba de eliminación de temas
  test 'delete' do
    assert_difference('Topic.count', -1) { @topic.destroy }
  end
  
  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @topic.code = '   '
    @topic.title = '   '
    assert @topic.invalid?
    assert_equal 2, @topic.errors.count
    assert_equal [error_message_from_model(@topic, :code, :blank)],
      @topic.errors[:code]
    assert_equal [error_message_from_model(@topic, :title, :blank)],
      @topic.errors[:title]
  
  end
  
  test 'validates formated attributes' do
    @topic.code = '1abc1'
    assert @topic.invalid?
    assert_equal 1, @topic.errors.count
    assert_equal [error_message_from_model(@topic, :code, :not_a_number)],
      @topic.errors[:code]
  end
  
end
