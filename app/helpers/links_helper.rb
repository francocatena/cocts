module LinksHelper
  def pagination_links(objects)
    will_paginate objects,
      :previous_label => "&laquo; #{t :'labels.previous'}",
      :next_label => "#{t :'labels.next'} &raquo;",
      :inner_window => 1,
      :outer_window => 1
  end

  def link_to_back
    link_to '&#x2190;'.html_safe, :back, :class => :iconic,
      :'data-show-tooltip' => true, :title => t(:'labels.back')
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
end
