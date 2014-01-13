module Reports::PdfProject
  def to_pdf
    i18n_scope = [:projects, :questionnaire]
    pdf = Prawn::Document.new(PDF_OPTIONS)
    pdf.font_size = PDF_FONT_SIZE

    add_presentation(pdf, i18n_scope)
    add_scale_explanation(pdf, i18n_scope)
    add_example_question(pdf)
    add_sociodemographic_forms(pdf, i18n_scope) if self.forms.present?
    prepare_questions(pdf)

    # Numeración en pie de página
    pdf.page_count.times do |i|
      pdf.go_to_page(i+1)
      pdf.draw_text "#{i+1} / #{pdf.page_count}", :at=>[1,1], :size => (PDF_FONT_SIZE * 0.75).round
    end

    FileUtils.mkdir_p File.dirname(self.pdf_full_path)

    pdf.render_file self.pdf_full_path
  end

  def add_presentation(pdf, i18n_scope)
    pdf.font_size((PDF_FONT_SIZE * 1.5).round) do
      pdf.text I18n.t(:presentation, :scope => i18n_scope), :style => :bold,
        :align => :center

      pdf.move_down pdf.font_size
    end

    pdf.font_size((PDF_FONT_SIZE * 0.85).round) do
      pdf.text I18n.t(:presentation_text, :scope => i18n_scope)
      pdf.move_down pdf.font_size
    end
  end

  def add_example_question(pdf)
    i18n_scope = [:projects, :questionnaire, :answer_example]

    pdf.move_down(pdf.font_size)
    pdf.text I18n.t(:title, :scope => i18n_scope), :style => :bold,
      :align => :center
    pdf.text I18n.t(:clarification, :scope => i18n_scope),
      :size => (PDF_FONT_SIZE * 0.75).round

    pdf.move_down(pdf.font_size)

    pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
      pdf.text I18n.t(:question, :scope => i18n_scope), :style => :bold_italic

      i18n_scope << :answers

      answers = [['A', 1], ['B', 6], ['C', 8], ['D', 9], ['E', 7], ['F', 8],
        ['G', 2]]

      answers.each do |letter, number|
        pdf.text(
          "[#{number}] #{letter}. #{I18n.t(letter, :scope => i18n_scope)}",
          :indent_paragraphs => pdf.font_size
        )
      end
    end
  end

  def add_sociodemographic_forms(pdf, i18n_scope)
    pdf.move_down(pdf.font_size)
    pdf.text I18n.t('sociodemographic_forms_title',
      :scope => i18n_scope).gsub(/\*/, '')

    self.forms.each do |form|
      pdf.font_size((PDF_FONT_SIZE * 0.6).round) do
        pdf.move_down(pdf.font_size)
        self.send(:"add_#{form}_form", pdf)
      end
    end
  end

  def pdf_name
    I18n.t(:'projects.pdf_name', :identifier => self.identifier)
  end

  def pdf_relative_path
    File.join(*(['pdfs'] + ('%08d' % self.id).scan(/..../) + [self.pdf_name]))
  end

  def pdf_full_path
    File.join(PUBLIC_PATH, self.pdf_relative_path)
  end

  def add_age_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :age])

    pdf.text "#{question} ______________"
  end

  def add_name_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :name])

    pdf.text "#{question} ______________"
  end

  def add_professor_name_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :professor_name])

    pdf.text "#{question} ______________"
  end

  def add_country_form(pdf)
    countries = []
    i18n_scope = [:projects, :questionnaire, :country, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :country])

    COUNTRIES.each_with_index do |country, i|
      countries << "[__] #{I18n.t(country, :scope => i18n_scope)} "
    end

    pdf.text "#{question} #{countries.join(' ')}"
  end

  def add_degree_school_form(pdf)
    degrees = []
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree_school])
    i18n_scope = [:projects, :sociodemographic_forms, :degree_school, :options]

    DEGREES_SCHOOL.each do |degree|
      degrees << "#{I18n.t(:'projects.sociodemographic_forms.degree_school.courses')}: [__] #{I18n.t(degree, :scope => i18n_scope)} "
    end

    pdf.text I18n.t(:'projects.sociodemographic_forms.degrees.question')
    pdf.move_down(pdf.font_size)
    pdf.text "#{question}: #{degrees.join(' ')}", :indent_paragraphs => 10
  end

  def add_degree_university_form(pdf)
    degrees = []
    i18n_scope = [:projects, :sociodemographic_forms, :degree_university, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree_university])

    DEGREES_UNIVERSITY.each_with_index do |degree, i|
      unless degree == DEGREES.last
        degrees << "#{I18n.t(:'projects.sociodemographic_forms.degree_university.degrees')}: [__] #{I18n.t(degree, :scope => i18n_scope)}"
      else
        degrees << "#{I18n.t(degree, :scope => i18n_scope)} ______________"
      end
    end

    pdf.text "#{question}: #{degrees.join(' ')}", :indent_paragraphs => 10
  end

  def add_study_subjects_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :study_subjects])

    pdf.text "#{question} ______________"
  end

  def add_educational_center_name_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :educational_center_name])

    pdf.text "#{question} ______________"
  end

  def add_educational_center_city_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :educational_center_city])

    pdf.text "#{question} ______________"
  end

  def add_study_subjects_different_form(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :study_subjects_different])

    pdf.text "#{question} ______________"
  end

  def add_study_subjects_choose_form(pdf)
    i18n_scope = [:projects, :sociodemographic_forms, :study_subjects_choose, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :study_subjects_choose])

    pdf.text "#{question}"

    STUDY_SUBJECTS_CHOOSE.each_with_index do |study, i|
      pdf.text "[__] #{I18n.t(study, :scope => i18n_scope)} ", :indent_paragraphs => 10
    end
  end

  def add_degree_form(pdf)
    degrees = []
    i18n_scope = [:projects, :questionnaire, :degree, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree])

    DEGREES.each_with_index do |degree, i|
      unless degree == DEGREES.last
        degrees << "#{I18n.t(degree, :scope => i18n_scope)} [__]"
      else
        degrees << "#{I18n.t(degree, :scope => i18n_scope)} ______________"
      end
    end

    pdf.text "#{question} #{degrees.join(' ')}"
  end

  def add_genre_form(pdf)
    genres = []
    i18n_scope = [:projects, :questionnaire, :genre, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :genre])

    GENRES.each_with_index do |genre, i|
      genres << "[__] #{I18n.t(genre, :scope => i18n_scope)} "
    end

    pdf.text "#{question} #{genres.join(' ')}"
  end

  def add_profession_form(pdf)
    data = []
    i18n_scope = [:projects, :questionnaire, :profession, :options]

    PROFESSIONS.each_with_index do |profession, i|
      data << [I18n.t(profession, :scope => i18n_scope), "[__]",
        "#{i+1} [__]"]
    end

    i18n_scope.slice!(-1)

    pdf.flexible_table data,
      :headers => [
        I18n.t(:question, :scope => [:projects, :sociodemographic_forms, :profession]),
        I18n.t(:certification, :scope => i18n_scope),
        I18n.t(:ocuppation, :scope => i18n_scope)
      ],
      :position => :center,
      :border_style => :grid,
      :size => (PDF_FONT_SIZE * 0.6).round,
      :vertical_padding => 3,
      :column_widths => {
        0 => pdf.margin_box.width * 0.7,
        1 => pdf.margin_box.width * 0.15,
        2 => pdf.margin_box.width * 0.15
      }
  end

  def add_student_form(pdf)
    student_statuses = []
    i18n_scope = [:projects, :questionnaire, :student, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :student])

    STUDENT_STATUSES.each_with_index do |student_status, i|
      student_statuses <<
        "[__] #{I18n.t(student_status, :scope => i18n_scope)} "
    end

    pdf.text "#{question} #{student_statuses.join(' ')}"
  end

  def add_teacher_form(pdf)
    teacher_statuses = []
    i18n_scope = [:projects, :questionnaire, :teacher, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :teacher])

    TEACHER_STATUSES.each_with_index do |teacher_status, i|
      teacher_statuses <<
        "[__] #{I18n.t(teacher_status, :scope => i18n_scope)} "
    end

    pdf.text "#{question} #{teacher_statuses.join(' ')}"
  end

  def add_teacher_level_form(pdf)
    teacher_levels = []
    i18n_scope = [:projects, :questionnaire, :teacher_level, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :teacher_level])

    TEACHER_LEVELS.each_with_index do |teacher_level, i|
      teacher_levels <<
        "[__] #{I18n.t(teacher_level, :scope => i18n_scope)} "
    end

    pdf.text "#{question} #{teacher_levels.join(' ')}"
  end

  def add_scale_explanation(pdf, i18n_scope)
    i18n_scope << :scale_table
    i18n_scope << :disagreement

    data = [[], ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'E', 'S']]

    [:'1', :'2', :'3', :'4'].each do |opt|
      data[0] << I18n.t(opt, :scope => i18n_scope)
    end

    i18n_scope[-1] = :undecided

    [:'5'].each { |opt| data[0] << I18n.t(opt, :scope => i18n_scope) }

    i18n_scope[-1] = :in_agreement

    [:'6', :'7', :'8', :'9'].each do |opt|
      data[0] << I18n.t(opt, :scope => i18n_scope)
    end

    i18n_scope[-1] = :others

    [:'E', :'S'].each { |opt| data[0] << I18n.t(opt, :scope => i18n_scope) }

    i18n_scope.slice!(-1)

    add_example_table(pdf, data, i18n_scope)

    i18n_scope.slice!(-1)

    pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
      pdf.move_down(pdf.font_size)
      pdf.text I18n.t(:scale_clarification, :scope => i18n_scope)
    end
  end

  def prepare_questions(pdf)
    pdf.start_new_page

    add_warning(pdf)

    if self.teaching_units.empty?
      self.questions.each do |question|
        add_question(pdf, question)
      end
    else
      add_teaching_units(pdf)
    end
  end

  def add_warning(pdf)
    i18n_scope = [:projects, :questionnaire]
    pdf.text I18n.t(:questions_warning, :scope => i18n_scope), :style => :bold,
      :align => :center
    pdf.move_down(pdf.font_size)
  end

  def add_question(pdf, question)
    letter = 'A'

    pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
      pdf.move_down(pdf.font_size)
      pdf.text "#{question.code} #{question.question}", :style => :bold_italic
      question.answers.each do |answer|
        pdf.text answer.clarification
        pdf.text "[__] #{letter}. #{answer.answer}",
          :indent_paragraphs => pdf.font_size
        letter.next!
      end
    end
  end

  def add_teaching_units(pdf)
    self.teaching_units.each do |teaching_unit|
      subtopic = teaching_unit.subtopic
      pdf.move_down(pdf.font_size)
      pdf.text "#{I18n.t('activerecord.models.teaching_unit')}: #{teaching_unit.title}", :style => :bold_italic

      if subtopic.present?
        pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
          pdf.move_down(pdf.font_size)
          pdf.text "#{t 'actioncontroller.subtopics'} #{subtopic.code} - #{subtopic.title}"
        end
      end

      teaching_unit.questions.each do |question|
        add_question(pdf, question)
      end
    end
  end

  def add_example_table(pdf, data, i18n_scope)
    pdf.flexible_table data,
      :headers => [
        {
          :text => I18n.t(:disagreement_title, :scope => i18n_scope),
          :colspan => 4
        },
        I18n.t(:undecided_title, :scope => i18n_scope),
        {
          :text => I18n.t(:in_agreement_title, :scope => i18n_scope),
          :colspan => 4
        },
        {:text => I18n.t(:others_title, :scope => i18n_scope), :colspan => 2}
      ],
      :width => pdf.margin_box.width,
      :align => :center,
      :vertical_padding => 3,
      :border_style => :grid,
      :size => (PDF_FONT_SIZE * 0.75).round
  end
end
