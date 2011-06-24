require 'test_helper'

class ProjectInstanceTest < ActiveSupport::TestCase
  fixtures :project_instances
  
  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @project_instance = ProjectInstance.find project_instances(:one).id
  end
  
  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of ProjectInstance, @project_instance
    assert_equal project_instances(:one).first_name, @project_instance.first_name
    assert_equal project_instances(:one).last_name, @project_instance.last_name
    assert_equal project_instances(:one).email, @project_instance.email
  end
  
  # Prueba la creación de una instancia de proyecto
  test 'create' do
    assert_difference 'ProjectInstance.count' do
      @project_instance = ProjectInstance.create(
        :first_name => 'Name',
        :last_name => 'Lastname',
        :email => 'email@cirope.com.ar',
        :question_instances => [question_instances(:one)],
        :project => projects(:manual)
      )
    end
  end
  
  # Prueba de actualización de una instancia de proyecto
  test 'update' do
    assert_no_difference 'ProjectInstance.count' do
      assert @project_instance.update_attributes(:first_name => 'Updated name',
        :email => 'email@cirope.com'),
        @project_instance.errors.full_messages.join('; ')
    end

    @project_instance.reload
    assert_equal 'Updated name', @project_instance.first_name
    assert_equal 'email@cirope.com', @project_instance.email
  end

  # Prueba de eliminación de instancias de proyectos
  test 'delete' do
    assert_difference('ProjectInstance.count', -1) { @project_instance.destroy }
  end
  
  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @project_instance.email = '   '
    assert @project_instance.invalid?
    assert_equal 1, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :email, :blank)],
      @project_instance.errors[:email]
  end
  
  test 'validates unique attributes' do
    @project_instance.email = project_instances(:two).email
    assert @project_instance.invalid?
    assert_equal 1, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :email, :taken)],
      @project_instance.errors[:email]
  end

  
  test 'validates lenght attributes' do
    @project_instance.first_name = 'abcde' * 52
    @project_instance.last_name = 'abcde' * 52
    assert @project_instance.invalid?
    assert_equal 2, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :first_name, :too_long,
      :count => 255)], @project_instance.errors[:first_name]
    assert_equal [error_message_from_model(@project_instance, :last_name, :too_long,
      :count => 255)], @project_instance.errors[:last_name]
  end
  
  test 'validates formated attributes' do
    @project_instance.email = 'name.com.ar'
    assert @project_instance.invalid?
    assert_equal 1, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :email, :invalid)],
      @project_instance.errors[:email]
  end
  
end
