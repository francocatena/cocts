module Projects::Rates
  def pdf_rates
    projects = Project.where('name = ?', @project.name).order('group_type DESC, test_type DESC')
    respond_to do |format|
       format.pdf  {
        @project.generate_pdf_rates(projects, @auth_user)
        redirect_to "/#{@project.pdf_relative_path}"
      }
    end
  end
end
