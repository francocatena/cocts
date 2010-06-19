require 'test_helper'

# Clase para probar el modelo "Project"
class ProjectTest < ActiveSupport::TestCase
  fixtures :projects

  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @project = Project.find projects(:manual).id
  end

  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of Project, @project
    assert_equal projects(:manual).name, @project.name
    assert_equal projects(:manual).identifier, @project.identifier
    assert_equal projects(:manual).description, @project.description
    assert_equal projects(:manual).year, @project.year
    assert_equal projects(:manual).project_type, @project.project_type
    assert_equal projects(:manual).valid_until, @project.valid_until
  end

  # Prueba la creación de un proyecto
  test 'create' do
    assert_difference 'Project.count' do
      @project = Project.create(
        :name => 'New name',
        :identifier => 'new-project',
        :description => 'New description',
        :year => 2010,
        :project_type => Project::TYPES[:manual],
        :valid_until => 20.days.from_now.to_date
      )
    end
  end

  # Prueba de actualización de un proyecto
  test 'update' do
    assert_no_difference 'Project.count' do
      assert @project.update_attributes(:name => 'Updated name'),
        @project.errors.full_messages.join('; ')
    end

    @project.reload
    assert_equal 'Updated name', @project.name
  end

  # Prueba de eliminación de proyectos
  test 'delete' do
    assert_difference('Project.count', -1) { @project.destroy }
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @project.name = '   '
    @project.identifier = '   '
    @project.description = '   '
    @project.valid_until = nil
    assert @project.invalid?
    assert_equal 4, @project.errors.count
    assert_equal error_message_from_model(@project, :name, :blank),
      @project.errors.on(:name)
    assert_equal error_message_from_model(@project, :identifier, :blank),
      @project.errors.on(:identifier)
    assert_equal error_message_from_model(@project, :description, :blank),
      @project.errors.on(:description)
    assert_equal error_message_from_model(@project, :valid_until, :blank),
      @project.errors.on(:valid_until)
  end

  test 'validates unique attributes' do
    @project.identifier = projects(:interactive).identifier
    assert @project.invalid?
    assert_equal 1, @project.errors.count
    assert_equal error_message_from_model(@project, :identifier, :taken),
      @project.errors.on(:identifier)
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates formated attributes' do
    @project.identifier = 'xx_'
    @project.valid_until = '13/13/13'
    assert @project.invalid?
    assert_equal 2, @project.errors.count
    assert_equal error_message_from_model(@project, :identifier, :invalid),
      @project.errors.on(:identifier)
    assert_equal error_message_from_model(@project, :valid_until,
      :invalid_date), @project.errors.on(:valid_until)
  end

  test 'validates lenght attributes' do
    @project.name = 'abcde' * 52
    @project.identifier = 'abcde' * 52
    assert @project.invalid?
    assert_equal 2, @project.errors.count
    assert_equal error_message_from_model(@project, :name, :too_long,
      :count => 255), @project.errors.on(:name)
    assert_equal error_message_from_model(@project, :identifier, :too_long,
      :count => 255), @project.errors.on(:identifier)
  end

  test 'validates included attributes' do
    @project.forms = ['invalid_form']
    assert @project.invalid?
    assert_equal 1, @project.errors.count
    assert_equal error_message_from_model(@project, :forms, :inclusion),
      @project.errors.on(:forms)
  end
end