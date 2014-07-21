module Autocompletes::Questions
  def autocomplete_for_question
    query = params[:q].sanitized_for_text_query
    @query_terms = query.split(/\s+/).reject(&:blank?)
    @questions = Question.all
    @questions = @questions.full_text(@query_terms) unless @query_terms.empty?
    @questions = @questions.limit(10)

    respond_to do |format|
      format.json { render json: @questions }
    end
  end
end
