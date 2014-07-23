class SubtopicsController < ApplicationController
  respond_to :html

  before_filter :auth
  before_filter :set_subtopic, only: [:show, :edit, :update, :destroy]

  # GET /subtopics
  def index
    @subtopics = Subtopic.search(params[:search], params[:page])
  end

  # GET /subtopics/1
  def show
  end

  # GET /subtopics/new
  def new
    @subtopic = Subtopic.new
  end

  # GET /subtopics/1/edit
  def edit
  end

  # POST /subtopics
  def create
    @subtopic = Subtopic.new(subtopic_params)
    @subtopic.save
    respond_with @subtopic, location: subtopics_url
  end

  # PUT /subtopics/1
  def update
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
  def destroy
    @subtopic.destroy
    respond_with @subtopic
  end

  def autocomplete_for_teaching_unit
    query = params[:q].sanitized_for_text_query
    @query_terms = query.split(/\s+/).reject(&:blank?)
    @teaching_units = TeachingUnit.all
    @teaching_units = @teaching_units.full_text(@query_terms) unless @query_terms.empty?
    @teaching_units = @teaching_units.limit(10)

    respond_to do |format|
      format.json { render json: @teaching_units }
    end
  end

  private

    def set_subtopic
      @subtopic = Subtopic.find(params[:id])
    end

    def subtopic_params
      params.require(:subtopic).permit(
        :title, :code, teaching_unit_ids: []
      )
    end
end
