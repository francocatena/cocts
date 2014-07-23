class SubtopicsController < ApplicationController
  include Autocompletes::TeachingUnits

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

    update_resource @subtopic, subtopic_params
    respond_with @subtopic
  end

  # DELETE /subtopics/1
  def destroy
    @subtopic.destroy
    respond_with @subtopic
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
