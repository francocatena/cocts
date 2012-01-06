class ProjectsController < ApplicationController
  before_filter :auth
  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  # * GET /projects
  # * GET /projects.xml
  def index
    @title = t :'projects.index_title'
    
    @projects = Project.order('name').paginate(
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
    params[:project][:question_ids] ||= []
    params[:project][:teaching_unit_ids] ||= []
    @project = Project.new(params[:project])
    @project.user = @auth_user
    
    if @project.questions.empty? && @project.teaching_units.empty?
      @project.errors[:base] << t(:'projects.empty_questions_error') 
      render :action => :new    
    elsif !@project.teaching_units.empty? && !@project.questions.empty?
      @project.errors[:base] << t(:'projects.questions_error') 
      render :action => :new
    
    else respond_to do |format|
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
    
  end

  # * PUT /projects/1
  # * PUT /projects/1.xml
  def update
    
    @title = t :'projects.edit_title'
        
    @project = Project.find_by_identifier(params[:id])
    params[:project][:question_ids] ||= []
    params[:project][:teaching_unit_ids] ||= []
        
    # Validación de que solo tenga cuestiones ya sean de UDs O cuestiones individuales
    if params[:project][:question_ids].empty? && params[:project][:teaching_unit_ids].empty? 
      @project.errors[:base] << t(:'projects.empty_questions_error') 
      render :action => :edit    
    # Validación de que no tenga cuestiones de UDs Y cuestiones individuales
    elsif !(params[:project][:question_ids].blank? || @project.questions.empty?) && !(params[:project][:teaching_unit_ids].blank? || @project.teaching_units.empty?)
      @project.errors[:base] << t(:'projects.questions_error') 
      render :action => :edit
    
    else respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = t :'projects.correctly_created'
        format.html { redirect_to projects_path }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
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
    unless @project.destroy
      flash[:alert] = t :'projects.project_instance_error'
    end
    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

  # POST /projects/auto_complete_for_question
  def autocomplete_for_question
    query = params[:q].sanitized_for_text_query
    @query_terms = query.split(/\s+/).reject(&:blank?)
    @questions = Question.scoped
    @questions = @questions.full_text(@query_terms) unless @query_terms.empty?
    @questions = @questions.limit(10)
        
    respond_to do |format|
      format.json { render :json => @questions }
    end
  end
  
  def preview_form
    render :partial => "#{params[:form]}"
  end
end