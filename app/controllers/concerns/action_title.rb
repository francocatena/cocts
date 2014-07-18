module ActionTitle
  extend ActiveSupport::Concern

  def set_title
    @title = t action_title
  end

  def action_aliases
    { create: 'new', update: 'edit' }.with_indifferent_access
  end

  private

    def action_title
      [controller_path.gsub('/', '.'), action_aliases[action_name] || action_name, 'title'].join '.'
    end
end
