module QuestionsHelper
  def answer_category_field(form)
    options = Answer::CATEGORIES.map do |k, v|
      [t("questions.answers.long_type.#{k}"), v]
    end

    form.select :category, sort_options_array(options), {:prompt => true}
  end

  def add_question_link
    link_to new_question_path, title: t('projects.add_question'), data: { remote: true } do
      content_tag :span, nil, class: 'glyphicon glyphicon-plus-sign'
    end
  end
end
