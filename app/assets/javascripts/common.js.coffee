# Mantiene el estado de la aplicación
State =
  # Contador para generar un ID único
  newIdCounter: 0

$ ->
  $('*[data-show-tooltip]').tooltip()
  $('*[data-show-popover]').popover()

  $("#questions_search input").keyup ->
    setTimeout(searchQuestions, 400)
    false

  $("#projects_search input").keyup ->
    setTimeout(searchQuestions, 400)
    false

searchQuestions = ->
  $.get($("#questions_search").attr("action"), $("#questions_search").serialize(), null, "script")

searchProjects = ->
  $.get($("#projects_search").attr("action"), $("#projects_search").serialize(), null, "script")

# Manejadores de eventos
EventHandler =
  # Agrega un ítem anidado
  addNestedItem: (e) ->
    template = eval(e.data('template'))
    $(e.data('container')).append(Util.replaceIds(template, /NEW_RECORD/g))
    e.trigger('item:added', e)

  # Oculta un elemento (agregado con alguna de las funciones para agregado dinámico)
  hideItem: (e) ->
    Helper.hideItem($(e).parents($(e).data('target')))
    $(e).prev('input[type=hidden].destroy').val('1')
    $(e).trigger('item:hidden', $(e))
    FormUtil.completeSortNumbers()

  # Elimina el elemento del DOM
   removeItem: (e) ->
    target = e.parents(e.data('target'))
    Helper.removeItem(target)
    target.trigger('item:removed', target)
    FormUtil.completeSortNumbers()

# Utilidades para formularios
window.FormUtil =
  # Completa todos los inputs con la clase "sort_number" con números en secuencia
   completeSortNumbers: ->
    $('input.sort_number').val((i) ->  i + 1)

# Utilidades varias para asistir con efectos sobre los elementos
window.Helper =
  # Oculta el elemento indicado
  hideItem: (element, callback) ->
    $(element).stop().slideUp(500, callback)

  # Convierte en "ordenable" (utilizando drag & drop) a un componente
  makeSortable: (elementId, elements, handles) ->
    $(elementId).sortable
      items: elements
      handle: handles
      opacity: 0.6
      stop: -> FormUtil.completeSortNumbers()
  # Elimina el elemento indicado
  removeItem: (element, callback) ->
    $(element).stop().slideUp 500, ->
      $(this).remove()
      if jQuery.isFunction(callback)
        callback()
    
# Utilidades varias
Util =
     # Reemplaza todas las ocurrencias de la expresión regular 'regex' con un ID
     # único generado con la fecha y un número incremental
  replaceIds: (s, regex) ->
    s.replace(regex, new Date().getTime() + State.newIdCounter++)

jQuery ($) ->
  eventList = $.map(EventHandler, (v, k ) -> k)

  # Para que los navegadores que no soportan HTML5 funcionen con autofocus
  $('*[autofocus]:not([readonly]):not([disabled]):visible:first').focus()

  $(document).on 'click', 'a[data-event]', (event) ->
    if (event.stopped)
      return
    element = $(this)
    eventName = element.data('event')
    if $.inArray(eventName, eventList) != -1
      EventHandler[eventName](element)
      event.preventDefault()
      event.stopPropagation()

  $(document).on 'change', 'input.autocomplete_field', ->
    element = $(this)

    if /^\s*$/.test(element.val())
      element.next('input.autocomplete_id:first').val('')

  $('#loading').bind
    ajaxStart: -> $(this).show()
    ajaxStop: -> $(this).hide()

  $(document).on 'focus', 'input.calendar:not(.hasDatepicker)', ->
    if $(this).data('time')
      $(this).datetimepicker(showOn: 'both').focus()
    else
      $(this).datepicker(showOn: 'both').focus()

  $(document).on 'click', 'a.search', (event) ->
    $('#search_form').fadeIn 300, -> $('#search_form *[autofocus]').focus()
    false

