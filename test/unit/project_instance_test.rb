# -*- coding: utf-8 -*-
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
    assert_equal project_instances(:one).professor_name, @project_instance.professor_name
    assert_equal project_instances(:one).email, @project_instance.email
  end

  # Prueba la creación de una instancia de proyecto
  test 'create' do
    assert_difference 'ProjectInstance.count' do
      @project_instance = ProjectInstance.create(
        :first_name => 'Name',
        :professor_name => 'Professor name',
        :email => 'email@cirope.com.ar',
        :age => 25,
        :degree => 'doctor',
        :genre => 'male',
        :student_status => 'no_study',
        :teacher_status => 'in_training',
        :teacher_level => 'primary',
        :educational_center_name => 'UNCuyo',
        :educational_center_city => 'Mza',
        :study_subjects_different => 2,
        :country => 'Brasil',
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

  test 'validates unique attributes' do
    @project_instance.first_name = project_instances(:two).first_name
    assert @project_instance.invalid?
    assert_equal 1, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :first_name, :taken)],
      @project_instance.errors[:first_name]
  end


  test 'validates lenght attributes' do
    @project_instance.first_name = 'abcde' * 52
    @project_instance.professor_name = 'abcde' * 52
    assert @project_instance.invalid?
    assert_equal 2, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :first_name, :too_long,
      :count => 255)], @project_instance.errors[:first_name]
    assert_equal [error_message_from_model(@project_instance, :professor_name, :too_long,
      :count => 255)], @project_instance.errors[:professor_name]
  end

  test 'validates blank attributes' do
    @project_instance.first_name = nil
    assert @project_instance.invalid?
    assert_equal 1, @project_instance.errors.count
    assert_equal [error_message_from_model(@project_instance, :first_name, :blank)],
      @project_instance.errors[:first_name]
  end

  test 'conversion to pdf' do
    FileUtils.rm @project_instance.pdf_full_path if File.exists?(@project_instance.pdf_full_path)

    assert !File.exists?(@project_instance.pdf_full_path)

    assert_nothing_raised(Exception) do
      @project_instance.to_pdf
    end

    assert File.exists?(@project_instance.pdf_full_path)

    FileUtils.rm @project_instance.pdf_full_path
  end

end
