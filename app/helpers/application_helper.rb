module ApplicationHelper
  # Devuelve el HTML devuelto por un render :partial => 'form', con el texto en
  # el botón submit reemplazado por el indicado. El resultado está "envuelto" en
  # un div con la clase "form_container"
  #
  # * _submit_label_::  Etiqueta que se quiere mostrar en el botón submit del
  #                     formulario
  def render_form(submit_label = t(:'labels.save'))
    content_tag :div, render(:partial => 'form',
      :locals => {:submit_text => submit_label}), :class => :form_container
  end

  # Devuelve el HTML con los links para navegar una lista paginada
  #
  # * _objects_:: Objetos con los que se genera la lista paginada
  def pagination_links(objects)
    will_paginate objects,
      :previous_label => "&laquo; #{t :'labels.previous'}",
      :next_label => "#{t :'labels.next'} &raquo;",
      :inner_window => 1,
      :outer_window => 1
  end

  # Devuelve el HTML de un vínculo para volver (history.back())
  def link_to_back
    link_to_function t(:'labels.back'), 'history.back()'
  end

  # Devuelve el HTML (con el tag <script>) para establecer el foco en un
  # elemento
  #
  # * _dom_id_::  ID del elemento al que se le quiere establecer el foco
  # * _delay_::   Delay en segundos que se quiere aplicar
  def set_focus_to(dom_id, delay = 0)
    javascript_tag "Form.Element.focus.delay(#{delay}, '#{dom_id.to_s}');"
  end

  # Devuelve el HTML (con el tag <script>) para establecer el foco en el primer
  # elemento del primer formulario declarado
  def set_focus_to_first_element
    javascript_tag 'FormHelper.focusFirst();'
  end

  # Devuelve el HTML de un campo lock_version oculto dentro de un div oculto
  #
  # * _form_:: Formulario que se utilizará para generar el campo oculto
  def hidden_lock_version(form)
    content_tag :div, form.hidden_field(:lock_version),
      :style => 'display: none;'
  end
end