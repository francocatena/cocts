# Mantiene el estado de la aplicación
State = 
  # Contador para generar un ID único
  newIdCounter: 0

# Funciones de autocompletado
window.AutoComplete = 
  observeAll: -> 
    $('input.autocomplete_field:not([data-observed])').each -> 
      input = $(this)
      input.autocomplete
        source: (request, response) -> 
          parameters = jQuery.parseJSON(input.data('params')) || {}
          parameters['q'] = request.term
          jQuery.ajax
            url: input.data('autocompleteUrl')
            dataType: 'json'
            data: parameters
            success: (data) -> 
              response jQuery.map data, (item) -> 
                content = $('<div>')
                content.append($('<span class="label">').text(item.label))
                if item.informal 
                  content.append($('<span class="informal">').text(item.informal))
                label: content.html(), value: item.label, item: item
               
        type: 'get'
        select: (event, ui) -> 
          selected = ui.item         
          input.val(selected.value)
          input.data('item', selected.item)
          input.next('input.autocomplete_id').val(selected.item.id)
          input.trigger('autocomplete:update', input)
          false
        
        open: -> $('.ui-menu').css('width', input.width())
      
      input.data('autocomplete')._renderItem = (ul, item) -> 
        $('<li></li>').data('item.autocomplete', item)
          .append($( "<a></a>" ).html(item.label)).appendTo( ul )
      
    .data('observed', true)
  
# Búsqueda de cuestiones
$ -> 
  $("#questions_search input").keyup -> 
    setTimeout(searchQuestions, 400)
    $(this).event.stopPropagation()
    false

searchQuestions = ->
  $.get($("#questions_search").attr("action"), $("#questions_search").serialize(), null, "script")
  
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
FormUtil = 
  # Completa todos los inputs con la clase "sort_number" con números en secuencia
   completeSortNumbers: -> 
    $('input.sort_number').val((i) ->  i + 1)
 
# Utilidades varias para asistir con efectos sobre los elementos
Helper = 
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

  $('a[data-event]').live 'click', (event) -> 
    if (event.stopped) 
      return
    element = $(this)
    eventName = element.data('event')
    if $.inArray(eventName, eventList) != -1
      EventHandler[eventName](element)
      event.preventDefault()
      event.stopPropagation()
   
  $('input.autocomplete_field').live 'change', -> 
    element = $(this)
    
    if /^\s*$/.test(element.val()) 
      element.next('input.autocomplete_id:first').val('')  
  
  $('#loading').bind
    ajaxStart: -> $(this).show()
    ajaxStop: -> $(this).hide()
    
  $('input.calendar:not(.hasDatepicker)').live 'focus', -> 
    if $(this).data('time') 
      $(this).datetimepicker(showOn: 'both').focus()
    else 
      $(this).datepicker(showOn: 'both').focus()
    
$('.hidden_dialog').dialog
  autoOpen: false
  draggable: false
  resizable: false
  close: -> 
    $(this).parents('.ui-dialog').show().fadeOut(500)  
  open: -> 
    $(this).parents('.ui-dialog').hide().fadeIn(500)
  
# Dialogs JQuery  
$('a.open_dialog').live 'click', (event) -> 
  $($(this).data('dialog')).dialog('open').dialog(
    'option', 'position', [
      event.pageX - $(window).scrollLeft(),
      event.pageY - $(window).scrollTop()
    ]
  )
  false

$('a.search').live 'click', (event) -> 
  $('#search_form').fadeIn(300)
  false
  AutoComplete.observeAll()
