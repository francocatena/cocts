module ProjectsHelper
  def project_type_field(form)
    options = Project::TYPES.map { |k, v| [t("projects.#{k}_type"), v] }

    form.select :project_type, sort_options_array(options), {:prompt => true}
  end
end
