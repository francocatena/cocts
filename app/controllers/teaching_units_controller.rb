class TeachingUnitsController < ApplicationController
  respond_to :html

  prepend_before_action :auth
  before_action :set_teaching_unit, only: [:show, :edit, :update, :destroy]
  before_action :set_title, except: :destroy

  # GET /teaching_units
  def index
    @teaching_units = TeachingUnit.search(params[:search], params[:page])
  end

  # GET /teaching_units/1
  def show
  end

  # GET /teaching_units/new
  def new
    @teaching_unit = TeachingUnit.new
  end

  # GET /teaching_units/1/edit
  def edit
  end

  # POST /teaching_units
  def create
    @teaching_unit = TeachingUnit.new(teaching_unit_params)

    @teaching_unit.save
    respond_with @teaching_unit, location: teaching_units_url
  end

  # PUT /teaching_units/1
  def update
    params[:teaching_unit][:question_ids] ||= []
    update_resource @teaching_unit, teaching_unit_params
    respond_with @teaching_unit, location: teaching_units_url
  end

  # DELETE /teaching_units/1
  def destroy
    @teaching_unit.destroy
    respond_with @teaching_unit, location: teaching_units_url
  end

  private

    def set_teaching_unit
      @teaching_unit = TeachingUnit.find(params[:id])
    end

    def teaching_unit_params
      params.require(:teaching_unit).permit(
        :title, question_ids: []
      )
    end
end
