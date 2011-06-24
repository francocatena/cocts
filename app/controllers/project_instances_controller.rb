class ProjectInstancesController < ApplicationController
  before_filter :auth
  # GET /project_instances
  # GET /project_instances.xml
  def index
    @title = t :'project_instances.index_title'
    if params[:id]
      @project_instances = ProjectInstance.where("project_id = ?", params[:id])
      @project = Project.find(params[:id])
    else
    @project_instances = ProjectInstance.all
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @project_instances }
    end
  end

  # GET /project_instances/1
  # GET /project_instances/1.xml
  def show
    @title = t :'project_instances.show_title'
    @project_instance = ProjectInstance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project_instance }
    end
  end

  # GET /project_instances/new
  # GET /project_instances/new.xml
  def new
    @title = t :'project_instances.new_title'
    @project = Project.find_by_identifier(params[:identifier])
    @project_instance = ProjectInstance.new(:project =>  @project)
        
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project_instance }
    end
  end

  # GET /project_instances/1/edit
  def edit
    @title = t :'project_instances.edit_title'
    @project_instance = ProjectInstance.find(params[:id])
  end

  # POST /project_instances
  # POST /project_instances.xml
  def create
    @title = t :'project_instances.new_title'
    @project_instance = ProjectInstance.new(params[:project_instance])

    respond_to do |format|
      if @project_instance.save
        flash[:notice] = t :'project_instances.correctly_created'
        format.html { redirect_to projects_path }
        format.xml  { render :xml => @project_instance, :status => :created, :location => @project_instance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /project_instances/1
  # PUT /project_instances/1.xml
  def update
    @project_instance = t :'project_instances.edit_title'
    @project_instance = ProjectInstance.find(params[:id])

    respond_to do |format|
      if @project_instance.update_attributes(params[:project_instance])
        format.html { redirect_to(@project_instance, :notice => 'Project instance was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /project_instances/1
  # DELETE /project_instances/1.xml
  def destroy
    @project_instance = ProjectInstance.find(params[:id])
    @project_instance.destroy

    respond_to do |format|
      format.html { redirect_to(project_instances_url) }
      format.xml  { head :ok }
    end
  end
end
