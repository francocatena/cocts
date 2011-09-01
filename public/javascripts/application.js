// Mantiene el estado de la aplicación
var State = {
  // Contador para generar un ID único
  newIdCounter: 0
}

// Funciones de autocompletado
var AutoComplete = {
  observeAll: function() {
    $('input.autocomplete_field:not([data-observed])').each(function(){
      var input = $(this);
      
      input.autocomplete({
        source: function(request, response) {
          var parameters = jQuery.parseJSON(input.data('params')) || {};
          
          parameters['q'] = request.term;
          
          return jQuery.ajax({
            url: input.data('autocompleteUrl'),
            dataType: 'json',
            data: parameters,
            success: function(data) {
              response(jQuery.map(data, function(item) {
                var content = $('<div>');
                  
                content.append($('<span class="label">').text(item.label));
          
                if(item.informal) {
                  content.append(
                    $('<span class="informal">').text(item.informal)
                  );
                }

                return { label: content.html(), value: item.label, item: item };
              })
              );
            }
          });
        },
        type: 'get',
        select: function(event, ui) {
          var selected = ui.item;
          
          input.val(selected.value);
          input.data('item', selected.item);
          input.next('input.autocomplete_id').val(selected.item.id);
          
          input.trigger('autocomplete:update', input);
          
          return false;
        },
        open: function() { $('.ui-menu').css('width', input.width()); }
      });
      
      input.data('autocomplete')._renderItem = function(ul, item) {
        return $('<li></li>').data('item.autocomplete', item)
          .append($( "<a></a>" ).html(item.label)).appendTo( ul );
      }
    }).data('observed', true);
  }
};

// Búsqueda de cuestiones
$(function() {
  $("#questions_search input").keyup(function() {
    $.get($("#questions_search").attr("action"), $("#questions_search").serialize(), null, "script");
    return false;
  });
});

// Manejadores de eventos
var EventHandler = {
  /**
     * Agrega un ítem anidado
     */
  addNestedItem: function(e) {
    var template = eval(e.data('template'));

    $(e.data('container')).append(Util.replaceIds(template, /NEW_RECORD/g));

    e.trigger('item:added', e);
  },

  /**
     * Oculta un elemento (agregado con alguna de las funciones para agregado
     * dinámico)
     */
  hideItem: function(e) {
    Helper.hideItem($(e).parents($(e).data('target')));

    $(e).prev('input[type=hidden].destroy').val('1');

    $(e).trigger('item:hidden', $(e));

    FormUtil.completeSortNumbers();
  },

  /**
     * Elimina el elemento del DOM
     */
  removeItem: function(e) {
    var target = e.parents(e.data('target'));

    Helper.removeItem(target);

    target.trigger('item:removed', target);

    FormUtil.completeSortNumbers();
  }
}

// Utilidades para formularios
var FormUtil = {
  /**
     * Completa todos los inputs con la clase "sort_number" con números en
     * secuencia
     */
  completeSortNumbers: function() {
    $('input.sort_number').val(function(i) { return i + 1; });
  }
}

// Utilidades varias para asistir con efectos sobre los elementos
var Helper = {
  /**
     * Oculta el elemento indicado
     */
  hideItem: function(element, callback) {
    $(element).stop().slideUp(500, callback);
  },

  /**
     * Convierte en "ordenable" (utilizando drag & drop) a un componente
     */
  makeSortable: function(elementId, elements, handles) {
    $(elementId).sortable({
      items: elements,
      handle: handles,
      opacity: 0.6,
      stop: function() { FormUtil.completeSortNumbers()}
    });
  },

  /**
     * Elimina el elemento indicado
     */
  removeItem: function(element, callback) {
    $(element).stop().slideUp(500, function() {
      $(this).remove();
      
      if(jQuery.isFunction(callback)) { callback(); }
    });
  }
}

// Utilidades varias
var Util = {
  /**
     * Reemplaza todas las ocurrencias de la expresión regular 'regex' con un ID
     * único generado con la fecha y un número incremental
     */
  replaceIds: function(s, regex){
    return s.replace(regex, new Date().getTime() + State.newIdCounter++);
  }
}

jQuery(function($) {
  var eventList = $.map(EventHandler, function(v, k ) { return k; });
  
  // Para que los navegadores que no soportan HTML5 funcionen con autofocus
  $('*[autofocus]:not([readonly]):not([disabled]):visible:first').focus();

  $('a[data-event]').live('click', function(event) {
    if (event.stopped) return;
    var element = $(this);
    var eventName = element.data('event');

    if($.inArray(eventName, eventList) != -1) {
      EventHandler[eventName](element);
      
      event.preventDefault();
      event.stopPropagation();
    }
  });
  
  $('input.autocomplete_field').live('change', function() {
    var element = $(this);
    
    if(/^\s*$/.test(element.val())) {
      element.next('input.autocomplete_id:first').val('');
    }
  });
  
  $('#loading').bind({
    ajaxStart: function() { $(this).show(); },
    ajaxStop: function() { $(this).hide(); }
  });
  
  $('input.calendar:not(.hasDatepicker)').live('focus', function() {
    if($(this).data('time')) {
      $(this).datetimepicker({showOn: 'both'}).focus();
    } else {
      $(this).datepicker({showOn: 'both'}).focus();
    }
  });
  
//$('.hidden_dialog').dialog({ autoOpen: false }); 
$('.hidden_dialog').dialog({
  autoOpen: false,
  draggable: false,
  resizable: false,
  close: function() {
    $(this).parents('.ui-dialog').show().fadeOut(500);
  },
  open: function(){
    $(this).parents('.ui-dialog').hide().fadeIn(500);
  }
});

// Dialogs JQuery  
$('a.open_dialog').live('click', function(event) {
  $($(this).data('dialog')).dialog('open').dialog(
    'option', 'position', [
      event.pageX - $(window).scrollLeft(),
      event.pageY - $(window).scrollTop()
    ]
  );
  
  return false;
});

$('a.search').live('click', function(event) {
  $('#search_form').fadeIn(300);
  
  return false;
});
  
  AutoComplete.observeAll();
});