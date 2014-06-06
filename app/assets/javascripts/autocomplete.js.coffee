class Autocomplete
  constructor: (@element) ->
    @targetElement = $ @element.data('autocompleteTarget')

    @_init()

  _init: ->
    @element.autocomplete
      source: (request, response) => @_source request, response
      type: 'get'
      minLength: @element.data 'autocompleteMinLength'
      select: (event, ui) => @_selected event, ui

    @_rewriteDefaultRenderItem()
    @_markAsObserved()
    @_listenChanges()

  _listenChanges: ->
    @element.change => @targetElement.val undefined unless @element.val().trim()

  _markAsObserved: -> @element.attr 'data-observed', true

  _renderItem: (item) ->
    content = $ '<div></div>'
    item.label ||= item.name

    content.append $('<span class="title"></span>').text item.label
    content.append $('<small></small>').text item.informal if item.informal

    label: content.html(), value: item.label, item: item

  _renderResponse: (data, response) ->
    if data.length
      response jQuery.map data, (item) => @_renderItem item
    else
      emptyResultLabel = @element.data('emptyResultLabel') || '---'

      response [ label: emptyResultLabel, value: '', item: {} ]

  _rewriteDefaultRenderItem: ->
    @element.data('ui-autocomplete')._renderItem = (ul, item) ->
      $('<li></li>').append($('<a></a>').html(item.label)).appendTo ul

  _selected: (event, ui) ->
    selected = ui.item

    @targetElement.val selected.item.id
    @element.val selected.value
    @element.trigger type: 'update.autocomplete', element: @element, item: selected.item

    false

  _source: (request, response) ->
    jQuery.ajax
      url: @element.data('autocompleteUrl')
      dataType: 'json'
      data: { q: request.term }
      success: (data) => @_renderResponse data, response

jQuery ($) ->
  selector = 'input[data-autocomplete-url]:not([data-observed])'

  $(document).on 'focus', selector, -> new Autocomplete $(this)
