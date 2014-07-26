module Reports::PdfProject
  def to_pdf
    @project = self.class.name.eql? 'Project'

    i18n_scope = [:projects, :questionnaire]
    pdf = Prawn::Document.new(PDF_OPTIONS)
    pdf.font_size = PDF_FONT_SIZE

    add_presentation(pdf, i18n_scope)
    add_scale_explanation(pdf, i18n_scope)
    @project ? add_example_question(pdf) :
      add_project_data(pdf)
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

  def add_project_data(pdf)
    pdf.move_down(pdf.font_size)
    pdf.text I18n.t('projects.questionnaire.project_data_title').gsub(/\*/, ''),
        :style => :bold
    pdf.move_down(pdf.font_size)

    i18n_scope = [:activerecord, :attributes, :project_instance]

    pdf.text "["+self.identifier+"] " + self.name
    pdf.text "#{I18n.t(:description, :scope => i18n_scope)}: #{self.description}"
    if self.year.present?
      pdf.text "#{I18n.t(:year, :scope => i18n_scope)}: #{self.year.to_s}"
    end
    pdf.text "#{I18n.t(:valid_until, :scope => i18n_scope)}: #{self.valid_until.to_formatted_s(:db)}"
    if self.group_name
      pdf.text "#{I18n.t(:group_name, :scope => i18n_scope)}: #{self.group_name}"
    end
    if self.group_type
      pdf.text "#{I18n.t(:group_type, :scope => i18n_scope)}: #{self.group_type}"
    end
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
    I18n.t('projects.pdf_name', :identifier => self.identifier)
  end

  def pdf_relative_path
    File.join(*(['pdfs'] + ('%08d' % self.id).scan(/..../) + [self.pdf_name]))
  end

  def pdf_full_path
    File.join(PUBLIC_PATH, self.pdf_relative_path)
  end

  def add_age_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.age.question')
    text = question + (@project ? ' ______________' : " #{self.age}")

    pdf.text text
  end

  def add_name_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.name.question')
    text = question + (@project ? ' ______________' : " #{self.first_name}")

    pdf.text text
  end

  def add_professor_name_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.professor_name.question')
    text = question + (@project ? ' ______________' : " #{self.professor_name}")

    pdf.text text
  end

  def add_country_form(pdf)
    countries = []
    question = I18n.t('projects.sociodemographic_forms.country.question')

    if @project
      i18n_scope = [:projects, :questionnaire, :country, :options]

      COUNTRIES.each_with_index do |country, i|
        countries << "[__] #{I18n.t(country, :scope => i18n_scope)} "
      end

      text = "#{question} #{countries.join(' ')}"

    else
      text = "#{question} #{self.country}"
    end

    pdf.text text
  end

  def add_degree_school_form(pdf)
    degrees = []
    question = I18n.t('projects.sociodemographic_forms.degree_school.question')
    i18n_scope = [:projects, :sociodemographic_forms, :degree_school, :options]

    if @project
      DEGREES_SCHOOL.each do |degree|
        degrees << "#{I18n.t('projects.sociodemographic_forms.degree_school.courses')}: [__] #{I18n.t(degree, :scope => i18n_scope)} "
      end

      text = "#{question}: #{degrees.join(' ')}"
    else
      text = "#{question}: #{I18n.t(self.degree_school, :scope => i18n_scope)}"
    end

    pdf.text text, indent_paragraphs: 10
  end

  def add_degree_university_form(pdf)
    i18n_scope = [:projects, :sociodemographic_forms, :degree_university, :options]

    if @project
      degrees = []
      question = I18n.t(:question,
        :scope => [:projects, :sociodemographic_forms, :degree_university])

      DEGREES_UNIVERSITY.each_with_index do |degree, i|
        unless degree == DEGREES.last
          degrees << "#{I18n.t(
              'projects.sociodemographic_forms.degree_university.degrees')
            }: [__] #{I18n.t(degree, :scope => i18n_scope)}"
        else
          degrees << "#{I18n.t(degree, :scope => i18n_scope)} ______________"
        end
      end

      text = pdf.text "#{question}: #{degrees.join(' ')}"
    else
      question = I18n.t(:question,
        :scope => [:projects, :sociodemographic_forms, :degree_university])
      text = "#{question}: #{I18n.t(self.degree_university, :scope => i18n_scope)}"
    end

    pdf.text text, :indent_paragraphs => 10
  end

  def add_study_subjects_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.study_subjects.question')
    text = question + (@project ? ' ______________' : " #{self.study_subjects}")

    pdf.text text
  end

  def add_educational_center_name_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.educational_center_name.question')
    text = question + (@project ? ' ______________' : " #{self.educational_center_name}")

    pdf.text text
  end

  def add_educational_center_city_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.educational_center_city.question')
    text = question + (@project ? ' ______________' : " #{self.educational_center_city}")

    pdf.text text
  end

  def add_study_subjects_different_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.study_subjects_different.question')
    text = question + (@project ? ' ______________' : " #{self.study_subjects_different}")

    pdf.text text
  end

  def add_study_subjects_choose_form(pdf)
    question = I18n.t('projects.sociodemographic_forms.study_subjects_choose.question')
    i18n_scope = [:projects, :sociodemographic_forms, :study_subjects_choose, :options]

    if @project
      pdf.text question

      STUDY_SUBJECTS_CHOOSE.each_with_index do |study, i|
        pdf.text "[__] #{I18n.t(study, :scope => i18n_scope)}", :indent_paragraphs => 10
      end
    else
      pdf.text "#{question} #{I18n.t(self.study_subjects_choose, :scope => i18n_scope)}"
    end
  end

  def add_degree_form(pdf)
    i18n_scope = [:projects, :questionnaire, :degree, :options]
    question = I18n.t('projects.sociodemographic_forms.degree.question')

    if @project
      degrees = []

      DEGREES.each_with_index do |degree, i|
        unless degree == DEGREES.last
          degrees << "#{I18n.t(degree, :scope => i18n_scope)} [__]"
        else
          degrees << "#{I18n.t(degree, :scope => i18n_scope)} ______________"
        end
      end

      pdf.text "#{question} #{degrees.join(' ')}"
    else
      pdf.text "#{question} #{I18n.t(self.degree, :scope => i18n_scope)}"
    end
  end

  def add_genre_form(pdf)
    i18n_scope = [:projects, :questionnaire, :genre, :options]
    question = I18n.t('projects.sociodemographic_forms.genre.question')

    if @project
      genres = []

      GENRES.each_with_index do |genre, i|
        genres << "[__] #{I18n.t(genre, :scope => i18n_scope)} "
      end

      pdf.text "#{question} #{genres.join(' ')}"
    else
      pdf.text "#{question} #{I18n.t(self.genre, :scope => i18n_scope)}"
    end
  end

  def add_profession_form(pdf)
    i18n_scope = [:projects, :questionnaire, :profession, :options]
    data = []

    PROFESSIONS.each_with_index do |profession, i|
      if @project
        data << [I18n.t(profession, :scope => i18n_scope), "[__]",
          "#{i+1} [__]"]
      else
        if self.profession_certification.include?(profession.to_s)
          certification = "X"
        else
          certification = "  "
        end
        if self.profession_ocuppation.include?(profession.to_s)
          ocuppation = "X"
        else
          ocuppation = "  "
        end

        data << [I18n.t(profession, :scope => i18n_scope), "#{i+1} [#{certification}]",
          "#{i+1} [#{ocuppation}]"]
      end
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
    i18n_scope = [:projects, :questionnaire, :student, :options]
    question = I18n.t('projects.sociodemographic_forms.student.question')

    if @project
      student_statuses = []
      STUDENT_STATUSES.each_with_index do |student_status, i|
        student_statuses <<
          "[__] #{I18n.t(student_status, :scope => i18n_scope)} "
      end

      pdf.text "#{question} #{student_statuses.join(' ')}"
    else
      pdf.text "#{question} #{I18n.t(self.student_status, :scope => i18n_scope)}"
    end
  end

  def add_teacher_form(pdf)
    i18n_scope = [:projects, :questionnaire, :teacher, :options]
    question = I18n.t('projects.sociodemographic_forms.teacher.question')

    if @project
      teacher_statuses = []
      TEACHER_STATUSES.each_with_index do |teacher_status, i|
        teacher_statuses <<
          "[__] #{I18n.t(teacher_status, :scope => i18n_scope)} "
      end

      pdf.text "#{question} #{teacher_statuses.join(' ')}"
    else
      pdf.text "#{question} #{I18n.t(self.teacher_status, :scope => i18n_scope)}"
    end
  end

  def add_teacher_level_form(pdf)
    i18n_scope = [:projects, :questionnaire, :teacher_level, :options]
    question = I18n.t('projects.sociodemographic_forms.teacher_level.question')

    if @project
      teacher_levels = []
      TEACHER_LEVELS.each_with_index do |teacher_level, i|
        teacher_levels <<
          "[__] #{I18n.t(teacher_level, :scope => i18n_scope)} "
      end

      pdf.text "#{question} #{teacher_levels.join(' ')}"
    else
      pdf.text "#{question} #{I18n.t(self.teacher_level, :scope => i18n_scope)}"
    end
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

    has_teaching_units = @project ? self.teaching_units.present? : 
      self.project.teaching_units.present?

    if has_teaching_units
      add_teaching_units(pdf)
    else
      questions = @project ? self.questions : self.project.questions

      questions.each do |question|
        add_question(pdf, question)
      end
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
          pdf.text "#{I18n.t 'actioncontroller.subtopics'} #{subtopic.code} - #{subtopic.title}"
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
