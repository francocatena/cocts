module LinksHelper
  def pagination_links(objects, params = nil)
    pagination_links = will_paginate objects,
      inner_window: 1, outer_window: 1, params: params,
      renderer: BootstrapPaginationHelper::LinkRenderer,
      class: 'pagination pagination-sm pull-right'
    page_entries = content_tag(:div,
      content_tag(:small,
        page_entries_info(objects),
        class: 'page-entries text-muted'
      ),
      class: 'hidden-lg pull-right'
    )

    pagination_links ||= empty_pagination_links

    content_tag(:div, pagination_links + page_entries, class: 'pagination-container')
  end

  def link_to_back
    link_to t('labels.back'), '#', 'data-event' => 'historyBack'
  end

  def remove_item_link(fields = nil, class_for_remove = nil)
    new_record = fields.nil? || fields.object.new_record?
    out = String.new.html_safe
    out << fields.hidden_field(:_destroy, :class => :destroy,
      :value => fields.object.marked_for_destruction? ? 1 : 0) unless new_record
    out << link_to('X', '#', :title => t(:'labels.delete'),
      :'data-target' => ".#{class_for_remove || fields.object.class.name.underscore}",
      :'data-event' => (new_record ? 'removeItem' : 'hideItem'))
  end

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

  def link_to_show(*args)
    link_with_icon({ action: 'show', icon: 'glyphicon-search' }, *args)
  end

  def link_to_edit(*args)
    link_with_icon({ action: 'edit', icon: 'glyphicon-pencil' }, *args)
  end

  def link_to_destroy(*args)
    options = args.extract_options!

    options[:data] ||= {}
    options[:data][:method] ||= :delete
    options[:data][:confirm] ||= t('messages.confirmation_question')

    link_with_icon({ action: 'destroy', icon: 'glyphicon-trash' }, *(args << options))
  end

  private
    def link_with_icon(options = {}, *args)
      arg_options = args.extract_options!

      arg_options.reverse_merge!(
        title: t("labels.#{options.fetch(:action)}"),
        class: 'icon'
      )

      link_to *args, arg_options do
        content_tag :span, nil, class: "glyphicon #{options.fetch(:icon)}"
      end
    end

  def empty_pagination_links
    previous_tag = content_tag(
      :li,
      content_tag(:a, t('will_paginate.previous_label').html_safe),
      class: 'previous disabled'
    )
    next_tag = content_tag(
      :li,
      content_tag(:a, t('will_paginate.next_label').html_safe),
      class: 'next disabled'
    )

    content_tag(:ul, previous_tag + next_tag, class: 'pager pull-right')
  end
end
