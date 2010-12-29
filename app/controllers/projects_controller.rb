class ProjectsController < ApplicationController
  before_filter :auth
  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  # * GET /projects
  # * GET /projects.xml
  def index
    @title = t :'projects.index_title'
    @projects = Project.order('valid_until DESC').paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE
    )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # * GET /projects/1
  # * GET /projects/1.xml
  def show
    @title = t :'projects.show_title'
    @project = Project.find_by_identifier(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
      format.pdf  {
        @project.to_pdf
        redirect_to "/#{@project.pdf_relative_path}"
      }
    end
  end

  # * GET /projects/new
  # * GET /projects/new.xml
  def new
    @title = t :'projects.new_title'
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # * GET /projects/1/edit
  def edit
    @title = t :'projects.edit_title'
    @project = Project.find_by_identifier(params[:id])
  end

  # * POST /projects
  # * POST /projects.xml
  def create
    @title = t :'projects.new_title'
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = t :'projects.correctly_created'
        format.html { redirect_to projects_path }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /projects/1
  # * PUT /projects/1.xml
  def update
    @title = t :'projects.edit_title'
    @project = Project.find_by_identifier(params[:id])
    params[:project][:question_ids] ||= []

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = t :'projects.correctly_updated'
        format.html { redirect_to projects_path }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t :'projects.stale_object_error'
    redirect_to edit_project_path(@project)
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find_by_identifier(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

  # POST /projects/auto_complete_for_question
  def auto_complete_for_question
    @tokens = params[:question_data][0..100].split(/[\s,]/).uniq
    @tokens.reject! {|t| t.blank?}
    conditions = []
    parameters = {}
    @tokens.each_with_index do |t, i|
      conditions << [
        "LOWER(#{Question.table_name}.code) LIKE :question_data_#{i}",
        "LOWER(#{Question.table_name}.question) LIKE :question_data_#{i}"
      ].join(' OR ')

      parameters[:"question_data_#{i}"] = "%#{t.downcase}%"
    end

    @questions = Question.where(
      [conditions.map {|c| "(#{c})"}.join(' AND '), parameters]
    ).order("#{Question.table_name}.code ASC").limit(10)
  end
end