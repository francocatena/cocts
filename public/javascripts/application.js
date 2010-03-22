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

                if(element && !readonly) { element.focus(); }
            } while(readonly);
        }
    }
}