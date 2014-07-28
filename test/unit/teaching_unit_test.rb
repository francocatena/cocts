# -*- coding: utf-8 -*-
require 'test_helper'

class TeachingUnitTest < ActiveSupport::TestCase
  fixtures :teaching_units

  # Función para inicializar las variables utilizadas en las pruebas
  def setup
    @teaching_unit = TeachingUnit.find teaching_units(:udI).id
  end

  # Prueba que se realicen las búsquedas como se espera
  test 'search' do
    assert_kind_of TeachingUnit, @teaching_unit
    assert_equal teaching_units(:udI).title, @teaching_unit.title
  end

  # Prueba la creación de una UD
  test 'create' do
    assert_difference 'TeachingUnit.count' do
      @teaching_unit = TeachingUnit.create(
        questions: [questions('10111')],
        title: 'Title'
      )
    end
  end

  # Prueba de actualización de una UD
  test 'update' do
    assert_no_difference 'TeachingUnit.count' do
      assert @teaching_unit.update_attributes(title: 'Updated title'),
        @teaching_unit.errors.full_messages.join('; ')
    end

    @teaching_unit.reload
    assert_equal 'Updated title', @teaching_unit.title
  end

  # Prueba de eliminación de UDs
  test 'delete' do
    assert_difference('TeachingUnit.count', -1) { @teaching_unit.destroy }
  end

  # Prueba que las validaciones del modelo se cumplan como es esperado
  test 'validates blank attributes' do
    @teaching_unit.questions.clear
    @teaching_unit.title = '   '
    assert @teaching_unit.invalid?
    assert_equal 2, @teaching_unit.errors.count
    assert_equal [error_message_from_model(@teaching_unit, :title, :blank)],
      @teaching_unit.errors[:title]

  end

end
