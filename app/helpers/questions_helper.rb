module QuestionsHelper
  def answer_category_field(form)
    options = Answer::CATEGORIES.map do |k, v|
      [t("questions.answers.long_type.#{k}"), v]
    end

    form.select :category, sort_options_array(options), {:prompt => true}
  end
end