// Mantiene el estado de la aplicación
var State = {
    // Contador para generar un ID único
    newIdCounter: 0
}

// Utilidades para asistir al autocompletado
var AutoComplete = {
    /**
     * Escribe en el primer campo oculto del contenedor de la búsqueda (div.search)
     * el ID del objeto seleccionado
     */
    itemSelected: function(text, li) {
        var objectId = $(li).id.strip().match(/id_(\d+)$/)[1];

        $(text).setValue($F(text).strip());
        $(text).up('div.search').select('.autocomplete_id_item').invoke(
            'setValue', objectId);
    }
}

// Manejadores de eventos
var EventHandler = {
    /**
     * Agrega un ítem anidado
     */
    addNestedItem: function(e) {
        var template = eval(e.readAttribute('data-template'));

        $(e.readAttribute('data-container')).insert({
            bottom: Util.replaceIds(template, /NEW_RECORD/)
        });
    },

    /**
     * Oculta un elemento (agregado con alguna de las funciones para agregado
     * dinámico)
     */
    hideItem: function(e) {
        var target = e.readAttribute('data-target');

        Helper.hideItem(e.up(target));

        var hiddenInput = e.previous('input[type=hidden].destroy');

        if(hiddenInput) {hiddenInput.setValue('1');}

        FormUtil.completeSortNumbers();
    },

    /**
     * Elimina el elemento del DOM
     */
    removeItem: function(e) {
        var target = e.readAttribute('data-target');

        Helper.removeItem(e.up(target));
        FormUtil.completeSortNumbers();
    }
}

// Utilidades para manipular formularios
var FormHelper = {
    /**
     * Establece el foco en el primer elemento, siempre que tenga sentido (un input,
     * un select, un textarea) y no esté deshabilitado o con el atributo readonly
     */
    focusFirst: function(container) {
        var c = $(container) || $$('form').first();

        if(c) {
            var index = 0;

            do {
                var focusables = [
                    '.focused',
                    'input[type=text]',
                    'select',
                    'textarea',
                    'input[type=password]'
                ].join(', ');
                var element = c.down(focusables, index++);
                var readonly = element && (element.readAttribute('readonly') ||
                    element.readAttribute('disabled'));

                if(element && !readonly) {element.focus();}
            } while(readonly);
        }
    }
}

// Utilidades para formularios
var FormUtil = {
    /**
     * Completa todos los inputs con la clase "sort_number" con números en
     * secuencia
     */
    completeSortNumbers: function() {
        var number = 1;

        $$('input.sort_number').each(function(e) { e.setValue(number++); });
    }
}

// Utilidades varias para asistir con efectos sobre los elementos
var Helper = {
    /**
     * Oculta el elemento indicado
     */
    hideItem: function(element, options) {
        Element.hide(element);
    },

    /**
     * Convierte en "ordenable" (utilizando drag & drop) a un componente
     */
    makeSortable: function(elementId, elements, handles) {
        Sortable.create(elementId, {
            scroll: window,
            elements: $$(elements),
            handles: $$(handles),
            onChange: function() { FormUtil.completeSortNumbers(); }
        });
    },

    /**
     * Elimina el elemento indicado
     */
    removeItem: function(element, options) {
        Element.remove(element);
        FormUtil.completeSortNumbers();
    }
}

// Utilidades varias
var Util = {
    /**
     * Reemplaza todas las ocurrencias de la expresión regular 'regex' con un ID
     * único generado con la fecha y un número incremental
     */
    replaceIds: function(s, regex){
        return s.gsub(regex, new Date().getTime() + State.newIdCounter++);
    }
}

var eventList = $H(EventHandler).keys();

// Funciones ejecutadas cuando se carga cada página
Event.observe(window, 'load', function() {
    if($('app_content')) {
        document.on('click', 'a[data-event]', function(event, element) {
            if (event.stopped) return;

            var eventName =
                element.readAttribute('data-event').dasherize().camelize();

            if(eventList.include(eventName)) {
                EventHandler[eventName](element);
                Event.stop(event);
            }
        });
    }
});