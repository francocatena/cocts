class SubtopicsController < ApplicationController
  before_filter :auth
  # GET /subtopics
  # GET /subtopics.json
  def index
    @subtopics = Subtopic.order("#{Subtopic.table_name}.code ASC").paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE
    )

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @subtopics }
    end
  end

  # GET /subtopics/1
  # GET /subtopics/1.json
  def show
    @subtopic = Subtopic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @subtopic }
    end
  end

  # GET /subtopics/new
  # GET /subtopics/new.json
  def new
    @subtopic = Subtopic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @subtopic }
    end
  end

  # GET /subtopics/1/edit
  def edit
    @subtopic = Subtopic.find(params[:id])
  end

  # POST /subtopics
  # POST /subtopics.json
  def create
    @subtopic = Subtopic.new(params[:subtopic])

    respond_to do |format|
      if @subtopic.save
        format.html { redirect_to subtopics_path, :notice => t(:'subtopic.correctly_created') }
        format.json { render :json => @subtopic, :status => :created, :location => @subtopic }
      else
        format.html { render :action => "new" }
        format.json { render :json => @subtopic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subtopics/1
  # PUT /subtopics/1.json
  def update
    @subtopic = Subtopic.find(params[:id])
    params[:subtopic][:teaching_unit_ids] ||= []
    
    respond_to do |format|
      if @subtopic.update_attributes(params[:subtopic])
        format.html { redirect_to @subtopic, :notice => t(:'subtopic.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @subtopic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subtopics/1
  # DELETE /subtopics/1.json
  def destroy
    @subtopic = Subtopic.find(params[:id])
    @subtopic.destroy

    respond_to do |format|
      format.html { redirect_to subtopics_url }
      format.json { head :ok }
    end
  end
  
   def auto_complete_for_teaching_unit
    tokens = params[:q][0..100].split(/[\s,]/).uniq
    tokens.reject! {|t| t.blank?}
    conditions = []
    parameters = {}
    tokens.each_with_index do |t, i|
      conditions << "LOWER(#{TeachingUnit.table_name}.title) LIKE :teaching_unit_data_#{i}"
      
      parameters[:"teaching_unit_data_#{i}"] = "%#{t.downcase}%"
    end

    @teaching_units = TeachingUnit.where(
      [conditions.map {|c| "(#{c})"}.join(' AND '), parameters]
    ).order("#{TeachingUnit.table_name}.title ASC").limit(10)
    
    respond_to do |format|
      format.json { render :json => @teaching_units }
    end
  end
end
