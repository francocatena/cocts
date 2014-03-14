class SubtopicsController < ApplicationController
  before_filter :auth
  # GET /subtopics
  # GET /subtopics.json
  def index
    @subtopics = Subtopic.search(params[:search], params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subtopics }
    end
  end

  # GET /subtopics/1
  # GET /subtopics/1.json
  def show
    @subtopic = Subtopic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subtopic }
    end
  end

  # GET /subtopics/new
  # GET /subtopics/new.json
  def new
    @subtopic = Subtopic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subtopic }
    end
  end

  # GET /subtopics/1/edit
  def edit
    @subtopic = Subtopic.find(params[:id])
  end

  # POST /subtopics
  # POST /subtopics.json
  def create
    @subtopic = Subtopic.new(subtopic_params)

    respond_to do |format|
      if @subtopic.save
        format.html { redirect_to subtopics_path, notice: t('subtopics.correctly_created') }
        format.json { render json: @subtopic, status: :created, location: @subtopic }
      else
        format.html { render action: "new" }
        format.json { render json: @subtopic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subtopics/1
  # PUT /subtopics/1.json
  def update
    @subtopic = Subtopic.find(params[:id])
    params[:subtopic][:teaching_unit_ids] ||= []

    respond_to do |format|
      if @subtopic.update_attributes(subtopic_params)
        format.html { redirect_to @subtopic, notice:  t('subtopics.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @subtopic.errors, status: :unprocessable_entity }
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

  def autocomplete_for_teaching_unit
    query = params[:q].sanitized_for_text_query
    @query_terms = query.split(/\s+/).reject(&:blank?)
    @teaching_units = TeachingUnit.all
    @teaching_units = @teaching_units.full_text(@query_terms) unless @query_terms.empty?
    @teaching_units = @teaching_units.limit(10)

    respond_to do |format|
      format.json { render :json => @teaching_units }
    end
  end

  private

  def subtopic_params
    params.require(:subtopic).permit(
      :title, :code, teaching_units_ids: []
    )
  end
end
