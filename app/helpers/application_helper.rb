# -*- coding: utf-8 -*-
module ApplicationHelper
  # Ordena un array que será utilizado en un select por el valor de los campos
  # que serán mostrados
  #
  # * _options_array_:: Arreglo con las opciones que se quieren ordenar
  def sort_options_array(options_array)
    options_array.sort { |o_1, o_2| o_1.first <=> o_2.first }
  end

  # Devuelve el HTML devuelto por un render :partial => 'form', con el texto en
  # el botón submit reemplazado por el indicado. El resultado está "envuelto" en
  # un div con la clase "form_container"
  #
  # * _submit_label_::  Etiqueta que se quiere mostrar en el botón submit del
  #                     formulario
  def render_form
    content_tag :div, render(:partial => 'form'), :class => :form_container
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
    link_to '&#x2190;'.html_safe, :back, :class => :iconic,
      :'data-show-tooltip' => true, :title => t(:'labels.back')
  end

  # Devuelve HTML con un link para eliminar un componente de un formulario
  #
  # * _fields_:: El objeto form para el que se va a generar el link
  def remove_item_link(fields = nil, class_for_remove = nil)
    new_record = fields.nil? || fields.object.new_record?
    out = String.new.html_safe
    out << fields.hidden_field(:_destroy, :class => :destroy,
      :value => fields.object.marked_for_destruction? ? 1 : 0) unless new_record
    out << link_to('X', '#', :title => t(:'labels.delete'),
      :'data-target' => ".#{class_for_remove || fields.object.class.name.underscore}",
      :'data-event' => (new_record ? 'removeItem' : 'hideItem'))
  end

   # Devuelve HTML con un link para eliminar un componente de una lista de un
  #  formulario
  #
  # * _fields_:: El objeto form para el que se va a generar el link
  def remove_list_item_link(fields, remove_class = nil)
    link_to('X', "#", :title => t(:'labels.delete'),
      :'data-target' => ".#{remove_class || fields.object.class.name.underscore}",
      :'data-event' => 'removeItem')
  end

  # Devuelve el HTML de un vínculo para mover un ítem.
  #
  # * <em>*args</em>:: Las mismas opciones que link_to sin la etiqueta
  def link_to_move(*args)
    options = {
      :class => 'image_link move',
      :onclick => 'return false;',
      :title => t(:'labels.move')
    }
    options.merge!(args.pop) if args.last.kind_of?(Hash)

    link_to(image_tag('move.gif', :size => '11x11', :alt => '[M]'), '#',
      *(args << options))
  end

  # Devuelve el HTML (con el tag <script>) para establecer el foco en un
  # elemento
  #
  # * _dom_id_::  ID del elemento al que se le quiere establecer el foco
  # * _delay_::   Delay en segundos que se quiere aplicar
  def set_focus_to(dom_id, delay = 0)
    javascript_tag "Form.Element.focus.delay(#{delay}, '#{dom_id.to_s}');"
  end

  # Devuelve el HTML de un campo lock_version oculto dentro de un div oculto
  #
  # * _form_:: Formulario que se utilizará para generar el campo oculto
  def hidden_lock_version(form)
    content_tag :div, form.hidden_field(:lock_version),
      :style => 'display: none;'
  end

  # Devuelve una etiqueta con el mismo nombre que el del objeto para que sea
  # reemplazado con un ID único por la rutina que reemplaza todo en el navegador
  def dynamic_object_id(prefix, form_builder)
    "#{prefix}_#{form_builder.object_name.to_s.gsub(/[_\]\[]+/, '_')}"
  end

  # Devuelve el HTML necesario para insertar un nuevo ítem en un nested form
  #
  # * _form_builder_::  Formulario "Padre" de la relación anidada
  # * _method_::        Método para invocar la relación anidada (por ejemplo, si
  #                     se tiene una relación Post > has_many :comments, el método
  #                     en ese caso es :comments)
  # * _user_options_::  Optiones del usuario para "personalizar" la generación de
  #                     HTML.
  #    :object => objeto asociado
  #    :partial => partial utilizado para generar el HTML
  #    form_builder_local => nombre de la variable que contiene el objeto form
  #    :locals => Hash con las variables locales que necesita el partial
  #    :child_index => nombre que se pondrá en el lugar donde se debe reemplazar
  #                    por el índice adecuado (por defecto NEW_RECORD)
  #    :is_dynamic => se establece a true si se está generando para luego ser
  #                   insertado múltiples veces.
  def generate_html(form_builder, method, user_options = {})
    options = {
      :object => form_builder.object.class.reflect_on_association(method).klass.new,
      :partial => method.to_s.singularize,
      :form_builder_local => :f,
      :locals => {},
      :child_index => 'NEW_RECORD',
      :is_dynamic => true
    }.merge(user_options)

    form_builder.fields_for(method, options[:object],
      :child_index => options[:child_index]) do |f|
      render(:partial => options[:partial], :locals => {
          options[:form_builder_local] => f,
          :is_dynamic => options[:is_dynamic]
        }.merge(options[:locals]))
    end
  end

  # Genera el mismo HTML que #generate_html con la diferencia que lo escapa para
  # que pueda ser utilizado en javascript.
  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end

  # Aplica la función textilize pero le quita el párrafo que la misma introduce
  def textilize_without_paragraph(text)
    textiled = textilize(text)
    textiled = textiled[3..-1] if textiled[0..2] == '<p>'
    textiled = textiled[0..-5] if textiled[-4..-1] == '</p>'

    textiled.html_safe
  end

  def calendar_text_field(form, attribute, time = false, value = nil)
    value ||= form.object.send(attribute)
    options = {:class => :calendar}

    options[:value] = l(value, :format => time ? :minimal : :default) if value
    options[:'data-time'] = true if time

    form.text_field attribute, options
  end

  def link_to_show(*args)
    options = args.extract_options!

    options['class'] ||= 'iconic'
    options['title'] ||= t('labels.show')
    options['data-show-tooltip'] ||= true

    args << options

    link_to '&#xe074;'.html_safe, *args
  end

  def link_to_edit(*args)
    options = args.extract_options!

    options['class'] ||= 'iconic'
    options['title'] ||= t('labels.edit')
    options['data-show-tooltip'] ||= true

    args << options

    link_to '&#x270e;'.html_safe, *args
  end

  def link_to_destroy(*args)
    options = args.extract_options!

    options['class'] ||= 'btn btn-small btn-danger'
    options['title'] ||= t('labels.delete')
    options['data'] ||= { :confirm => t('messages.confirmation_question') }
    options['method'] ||= :delete

    args << options

    link_to "<span class=iconic>&#xe05a;</span> #{t:'labels.delete'}".html_safe,
      *args
  end

end
