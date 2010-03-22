class ProjectsController < ApplicationController
  before_filter :auth

  # * GET /projects
  # * GET /projects.xml
  def index
    @title = t :'projects.index_title'
    @projects = Project.paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE,
      :order => 'valid_until DESC'
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
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
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
    @project = Project.find(params[:id])
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
    @project = Project.find(params[:id])

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
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end