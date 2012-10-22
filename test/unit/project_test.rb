# -*- coding: utf-8 -*-
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
        :test_type => 'Pre-test',
        :group_name => 'New group',
        :group_type => 'control',
        :project_type => Project::TYPES[:manual],
        :valid_until => 20.days.from_now.to_date,
        :questions => [questions(:_10111)]
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
    assert_no_difference('Project.count') { @project.destroy }
    @project.project_instances.clear
    assert_difference('Project.count', -1) { @project.destroy }
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @project.name = '   '
    @project.description = '   '
    @project.test_type = '   '
    @project.group_type = '   '
    @project.group_name = '   '
    @project.valid_until = nil
    assert @project.invalid?
    assert_equal 6, @project.errors.count
    assert_equal [error_message_from_model(@project, :name, :blank)],
      @project.errors[:name]
    assert_equal [error_message_from_model(@project, :description, :blank)],
      @project.errors[:description]
    assert_equal [error_message_from_model(@project, :valid_until,
        :blank)], @project.errors[:valid_until]
    assert_equal [error_message_from_model(@project, :test_type,
        :blank)], @project.errors[:test_type]
    assert_equal [error_message_from_model(@project, :group_type,
        :blank)], @project.errors[:group_type]
    assert_equal [error_message_from_model(@project, :group_name,
        :blank)], @project.errors[:group_name]
  end

  test 'validates unique attributes' do
    @project.identifier = projects(:interactive).identifier
    assert @project.invalid?
    assert_equal 1, @project.errors.count
    assert_equal [error_message_from_model(@project, :identifier, :taken)],
      @project.errors[:identifier]
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates formated attributes' do
    @project = Project.find projects(:interactive).id
    @project.identifier = 'admin'
    @project.valid_until = '10/10/10'
    assert @project.invalid?
    assert_equal 2, @project.errors.count
    assert_equal [error_message_from_model(@project, :identifier, :exclusion)],
      @project.errors[:identifier]
    assert_equal [error_message_from_model(@project, :valid_until,
      :on_or_after, :restriction => Time.now.strftime('%d/%m/%Y'))],
      @project.errors[:valid_until]

  end

  test 'validates lenght attributes' do
    @project.name = 'abcde' * 52
    @project.identifier = 'abcde' * 52
    assert @project.invalid?
    assert_equal 2, @project.errors.count
    assert_equal [error_message_from_model(@project, :name, :too_long,
      :count => 255)], @project.errors[:name]
    assert_equal [error_message_from_model(@project, :identifier, :too_long,
      :count => 255)], @project.errors[:identifier]
  end

  test 'validates included attributes' do
    @project.forms = ['invalid_form']
    @project.identifier = 'admin'
    assert @project.invalid?
    assert_equal 2, @project.errors.count
    assert_equal [error_message_from_model(@project, :forms, :inclusion)],
      @project.errors[:forms]
    assert_equal [error_message_from_model(@project, :identifier, :exclusion)],
      @project.errors[:identifier]
  end

  test 'generate project identifier' do
    id_project = @project.generate_identifier
    id = "#{@project.id}-#{@project.short_group_type_text}-#{@project.short_test_type_text}"
    assert_equal id_project, id
  end

  test 'conversion to pdf' do
    FileUtils.rm @project.pdf_full_path if File.exists?(@project.pdf_full_path)

    assert !File.exists?(@project.pdf_full_path)
    assert_nothing_raised(Exception) do
      @project.to_pdf
    end
    assert File.exists?(@project.pdf_full_path)
    FileUtils.rm @project.pdf_full_path
  end

  test 'rates to pdf' do
    FileUtils.rm @project.pdf_full_path if File.exists?(@project.pdf_full_path)
    projects = Project.where(:name => @project.name)

    assert !File.exists?(@project.pdf_full_path)
    assert_nothing_raised(Exception) do
      @project.generate_pdf_rates(projects, User.first)
    end

    assert File.exists?(@project.pdf_full_path)
    FileUtils.rm @project.pdf_full_path
  end

end
