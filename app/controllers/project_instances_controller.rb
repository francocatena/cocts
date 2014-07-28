class ProjectInstancesController < ApplicationController
  respond_to :html

  before_action :auth, except: [:new, :create]
  before_action :load_auth_user, only: [:new, :create]
  before_action :set_title, except: :destroy
  before_action :set_project_instance, only: [:show, :edit, :update, :destroy]

  # GET /project_instances
  def index
    if params[:id]
      @project_instances = ProjectInstance.with_project(params[id]).paginate(page: params[:page],
       per_page: APP_LINES_PER_PAGE)
      @project = Project.find(params[:id])
    else
      @project_instances = ProjectInstance.all.paginate(page: params[:page],
       per_page: APP_LINES_PER_PAGE)
    end
  end

  # GET /project_instances/1
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.pdf  {
        @project_instance.to_pdf
        redirect_to "/#{@project_instance.pdf_relative_path}"
      }
    end
  end

  # GET /project_instances/new
  def new
    session[:go_to] = request.env['HTTP_REFERER']

    if params[:identifier]
      @project = Project.find_by_identifier(params[:identifier])
      @project_instance = ProjectInstance.new(project: @project)
    else
      @project = Project.find_by_identifier(request.subdomains.first)
      if @project
        unless @project.is_valid?
          flash[:alert]= t 'projects.valid_until_error'
          redirect_to login_users_path
        end
        if @project.interactive?
          @project_instance = ProjectInstance.new(project: @project)
        else
          flash[:alert]= t 'project_instances.error_manual_type'
          redirect_to login_users_path
        end
      else
        flash[:alert]= t 'project_instances.error_subdomain'
        redirect_to login_users_path
      end
    end
  end

  # GET /project_instances/1/edit
  def edit
    session[:go_to] = request.env['HTTP_REFERER']
  end


  # POST /project_instances
  def create
    @project_instance = ProjectInstance.new(project_instance_params)

    respond_to do |format|
      if @project_instance.save
        if @project_instance.manual?
          go_to = session[:go_to]
          session[:go_to] = nil
          flash[:notice] = t 'project_instances.correctly_created'
          if go_to
            format.html { redirect_to go_to }
          else
            format.html { redirect_to projects_path }
          end
        else
          flash[:notice] = t 'project_instances.correctly_created_interactive'
          format.html { render action: 'show', id: @project_instance.to_param}
        end
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /project_instances/1
  def update
    update_resource @project_instance, project_instance_params
    go_to = session[:go_to] ||= project_instance_url

    respond_with @project_instance, location: go_to
  end

  # DELETE /project_instances/1
  def destroy
    id = @project_instance.project_id
    @project_instance.destroy

    respond_with @project_instance, location: project_instances_url
  end

  private

    def set_project_instance
      @project_instance = ProjectInstance.find(params[:id])
    end

    def project_instance_params
      params.require(:project_instance).permit(
        :first_name, :professor_name, :email, :name, :identifier, :description, :age,
        :degree, :genre, :student_status, :teacher_level, :teacher_status, :country,
        :educational_center_name, :educational_center_city, :study_subjects_different,
        :year, :project_type, :valid_until, :country, :study_subjects, :project_type,
        :study_subjects_choose, :degree_school, :manual_degree_university, :group_type,
        :group_name, :project_id,
        question_instances_attributes: [
          :question_id, :question_text, answer_instances_attributes: [
            :answer_id, :valuation, :order, :answer_text, :answer_category
          ]
        ]
      )
    end
end
