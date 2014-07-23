module Autocompletes::TeachingUnits
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
end
