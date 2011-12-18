class TopicsController < ApplicationController
  before_filter :auth
  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.order("#{Topic.table_name}.code ASC").paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE
    )

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.json
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to topics_path, :notice => t(:'topic.correctly_created') }
        format.json { render :json => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.json { render :json => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
    @topic = Topic.find(params[:id])
    params[:topic][:subtopic_ids] ||= []

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to @topic, :notice => t(:'topic.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :ok }
    end
  end
  
  def autocomplete_for_subtopic
    tokens = params[:q][0..100].split(/[\s,]/).uniq
    tokens.reject! {|t| t.blank?}
    conditions = []
    parameters = {}
    tokens.each_with_index do |t, i|
      conditions << "LOWER(#{Subtopic.table_name}.title) LIKE :subtopic_data_#{i}"
      
      parameters[:"subtopic_data_#{i}"] = "%#{t.downcase}%"
    end

    @subtopics = Subtopic.where(
      [conditions.map {|c| "(#{c})"}.join(' AND '), parameters]
    ).order("#{Subtopic.table_name}.title ASC").limit(10)
    
    respond_to do |format|
      format.json { render :json => @subtopics }
    end
  end
  
end
