class ProjectsController < ApplicationController
  respond_to :html

  before_action :auth
  before_action :set_title, except: [:destroy, :pdf_rates]
  before_action :set_project, only: [:show, :edit, :update, :destroy, :pdf_rates]
  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  # * GET /projects
  def index
    @projects = Project.search(params[:search], @auth_user, params[:page])
  end

  # * GET /projects/1
  def show

    respond_to do |format|
      format.html
      format.pdf  {
        @project.to_pdf
        redirect_to "/#{@project.pdf_relative_path}"
      }
    end
  end

  # * GET /projects/new
  def new
    @project = Project.new
    session[:go_to] = request.env['HTTP_REFERER']

    if params[:project_name].present?
      @name = true
      project = Project.find_by_name params[:project_name]
      @project.set_parent_data(project)
      @type = project.group_type
      @test = project.test_type
    end
  end

  # * GET /projects/1/edit
  def edit
    session[:go_to] = request.env['HTTP_REFERER']
  end

  # * POST /projects
  def create
    params[:project][:question_ids] ||= []
    params[:project][:teaching_unit_ids] ||= []
    @project = Project.new(project_params)
    @project.user = @auth_user unless @auth_user.admin

    if !(@project.questions.empty? ^ @project.teaching_units.empty?)
      @project.errors[:base] << t(:'projects.empty_questions_error')
      render :action => :new
    else
      respond_to do |format|
        @project.transaction do
          if @project.save
            @project.generate_identifier
            go_to = session[:go_to]
            session[:go_to] = nil
            flash[:notice] = t :'projects.correctly_created'
            if go_to
              format.html { redirect_to go_to }
            else
              format.html { redirect_to projects_path }
            end

            format.xml  { render :xml => @project, :status => :created, :location => @project }
          else
            format.html { render :action => :new }
            format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
          end
        end
      end
    end
  end

  # * PUT /projects/1
  def update
    params[:project][:question_ids] ||= []
    params[:project][:teaching_unit_ids] ||= []

    if !(params[:project][:question_ids].empty? ^ params[:project][:teaching_unit_ids].empty?)
      @project.errors[:question_ids] << t(:'projects.empty_questions_error')
      render :action => :edit
    else
      update_resource @project, project_params
      @project.generate_identifier
      @project.user = @auth_user unless @auth_user.admin
      respond_with @project, location: projects_url unless response_body
    end
  end

  # DELETE /projects/1
  def destroy
    flash[:alert] = t 'projects.project_instance_error' unless @project.destroy

    respond_with @project, location: projects_url
  end

  def pdf_rates
    projects = Project.where('name = ?', @project.name).order('group_type DESC, test_type DESC')
    respond_to do |format|
       format.pdf  {
        @project.generate_pdf_rates(projects, @auth_user)
        redirect_to "/#{@project.pdf_relative_path}"
      }
    end
  end

  def select_new
    if @auth_user.private
      @projects = Project.select('distinct name').where('user_id = ?', @auth_user.id)
    elsif @auth_user.admin
      @projects = Project.select('distinct name')
    else
      @projects = Project.joins(:user).select('distinct projects.name').where(
        "#{User.table_name}.private" => false)
    end
  end

  # POST /projects/auto_complete_for_question
  def autocomplete_for_question
    query = params[:q].sanitized_for_text_query
    @query_terms = query.split(/\s+/).reject(&:blank?)
    @questions = Question.all
    @questions = @questions.full_text(@query_terms) unless @query_terms.empty?
    @questions = @questions.limit(10)

    respond_to do |format|
      format.json { render :json => @questions }
    end
  end

  def preview_form
    render partial: "#{params[:form]}"
  end

  private
    def set_project
      @project = Project.find_by_identifier(params[:id])
    end

    def project_params
      params.require(:project).permit(
        :name, :description, :year, :user_id, :group_name, :group_type,
        :lock_version, :test_type, :project_type, :valid_until, forms: [], question_ids: [],
        teaching_unit_ids: []
      )
    end
end
