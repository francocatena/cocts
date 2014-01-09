module Reports::AttitudinalRates

  def generate_pdf_rates(projects, user)
    pdf = Prawn::Document.new(PDF_OPTIONS)
    pdf.font_size = PDF_FONT_SIZE

    add_generated_label(pdf, user)
    add_question_codes(pdf)
    add_attitudinal_title(pdf)
    data = []

    projects.each do |project|
      if project.project_instances.present?
        add_group_label(pdf, project)
        add_test_label(pdf, project)

        prepare_alumn_rates(pdf, project)
        prepare_question_rates(pdf, project)
        add_answer_category_rates(pdf)
      end
    end

    add_footer(pdf)
    render_file(pdf)
  end

  def add_group_label(pdf, project)
    if project.group_type == 'control'
      pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
        pdf.move_down pdf.font_size
        pdf.text I18n.t('projects.control_group_title')
      end
    elsif project.group_type == 'experimental'
      pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
        pdf.move_down pdf.font_size
        pdf.text I18n.t('projects.experimental_group_title')
      end
    end
  end

  def add_test_label(pdf, project)
    if project.test_type == 'pre_test'
      pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
        pdf.text I18n.t('projects.questionnaire.test_type.options.pre_test')
      end
    else
      pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
        pdf.text I18n.t('projects.questionnaire.test_type.options.pos_test')
      end
    end

    pdf.move_down pdf.font_size
  end

  def add_question_codes(pdf)
    question_codes = []
    if self.teaching_units.present?
      pdf.font_size((PDF_FONT_SIZE * 1.4).round) do
        pdf.move_down pdf.font_size
        pdf.text I18n.t('actioncontroller.teaching_units')
        pdf.move_down pdf.font_size
      end
      self.teaching_units.each do |unit|
        unit.questions.each do |question|
          question_codes << question.code
        end
        pdf.font_size((PDF_FONT_SIZE * 1.1).round) do
          pdf.text "#{unit.title} (#{question_codes.join(', ')})"
          pdf.move_down pdf.font_size
        end
      end
    elsif self.questions.present?
      pdf.font_size((PDF_FONT_SIZE * 1.4).round) do
        self.questions.each do |question|
          question_codes += question.code
        end
        pdf.move_down pdf.font_size
        pdf.text "#{I18n.t('actioncontroller.questions')}: #{question_codes.join(', ')}"
        pdf.move_down pdf.font_size
      end
    end
  end

  def add_attitudinal_title(pdf)
    pdf.font_size((PDF_FONT_SIZE * 1.4).round) do
      pdf.move_down pdf.font_size
      pdf.text I18n.t('projects.attitudinal_index_title')
      pdf.move_down pdf.font_size
    end
  end

  def add_generated_label(pdf, user)
    date = I18n.l(Date.today, :format => :long)
    name = "#{user.name} #{user.lastname}"

    pdf.font_size((PDF_FONT_SIZE * 0.7).round) do
      pdf.move_down pdf.font_size
      pdf.text "#{I18n.t 'labels.generated_on'} #{date} #{I18n.t 'labels.by'} #{name}", :align => :right
    end

    pdf.font_size((PDF_FONT_SIZE * 1.6).round) do
      pdf.move_down pdf.font_size
      pdf.text "#{I18n.t('activerecord.models.project')} #{self.name}", :style => :bold,
        :align => :center
      pdf.move_down pdf.font_size
    end
  end

  def standard_deviation(average)
    summation = 0
    n = 0
    self.project_instances.each do |instance|
      instance.question_instances.each do |question|
        question.answer_instances.each do |answer|
          if attitudinal_assessment = answer.calculate_attitudinal_assessment
            summation += (attitudinal_assessment - average) ** 2
            n += 1
          end
        end
      end
    end

    if n > 1
      Math.sqrt(summation.abs / (n - 1))
    else
      0
    end
  end

  def add_footer(pdf)
    pdf.page_count.times do |i|
      pdf.go_to_page(i+1)
      pdf.draw_text "#{i+1} / #{pdf.page_count}", :at=>[1,1], :size => (PDF_FONT_SIZE * 0.75).round
    end
  end

  def render_file(pdf)
    FileUtils.mkdir_p File.dirname(self.pdf_full_path)
    pdf.render_file self.pdf_full_path
  end

  def prepare_alumn_rates(pdf, project)
    alumn_rates = []
    professors = []

    @adecuate_index = @plausible_index = @naive_index = @global_index = 0
    @count = attitudinal_assessments = answers = 0

    alumn_rates << [I18n.t('projects.alumn_title'), I18n.t('projects.global_attitudinal_index_title'), I18n.t('projects.standard_deviation')]

    project.project_instances.each_with_index do |instance, i|
      alumn_answers = 0
      alumn_assessments = 0

      if professors.exclude?(instance.professor_name.try(:titleize)) && instance.professor_name
        professors << instance.professor_name.titleize
      end

      instance.calculate_attitudinal_rates
      attitudinal_global_index = instance.attitudinal_global_index

      @adecuate_index += instance.adecuate_attitude_index
      @plausible_index += instance.plausible_attitude_index
      @naive_index += instance.naive_attitude_index
      @global_index += instance.attitudinal_global_index

      instance.question_instances.each do |question|
        question.answer_instances.each do |answer|
          if answer.attitudinal_assessment.present?
            attitudinal_assessments += answer.attitudinal_assessment
            answers += 1
            alumn_assessments += answer.attitudinal_assessment
            alumn_answers += 1
          end
        end
      end

      unless alumn_answers == 0
        average_assessments = alumn_assessments / alumn_answers
        @count += 1
        alumn_rates << [instance.student_data, '%.2f' % average_assessments,
           '%.2f' % instance.standard_deviation(average_assessments)
        ]
      end
    end

    if professors.present?
      pdf.text I18n.t('activerecord.attributes.project_instance.professor_name') + ': ' + professors.join(', ')
      pdf.move_down pdf.font_size
    end

    add_pdf_table(pdf, alumn_rates)

    unless answers == 0
      pdf.text "#{I18n.t('projects.global_attitudinal_index_title')}: #{'%.2f' % (attitudinal_assessments / answers)}"
    end
  end

  def add_answer_category_rates(pdf)
    category_rates = []

    pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
      pdf.move_down pdf.font_size
      pdf.text I18n.t('projects.attitudinal_index_by_category_title')
      pdf.move_down pdf.font_size
    end

    unless @count == 0
      category_rates << [I18n.t('activerecord.attributes.answer.category'), I18n.t('projects.attitudinal_index_title'),
        I18n.t('projects.standard_deviation')
      ]
      category_rates << [I18n.t('questions.answers.long_type.adecuate'), '%.2f' % (@adecuate_index/@count),
        '%.2f' % standard_deviation_by_answer_type(@adecuate_index/@count, CATEGORIES[:adecuate])]
      category_rates << [I18n.t('questions.answers.long_type.plausible'), '%.2f' % (@plausible_index/@count),
        '%.2f' % standard_deviation_by_answer_type(@plausible_index/@count, CATEGORIES[:plausible])]
      category_rates << [I18n.t('questions.answers.long_type.naive'), '%.2f' % (@naive_index/@count),
        '%.2f' % standard_deviation_by_answer_type(@naive_index/@count, CATEGORIES[:naive])]

      add_pdf_table(pdf, category_rates)

      pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
        pdf.move_down pdf.font_size
        pdf.text "#{I18n.t 'projects.attitudinal_global_index'}: %.2f" % (@global_index/@count)
        pdf.move_down pdf.font_size
        pdf.text "#{I18n.t 'projects.standard_deviation'}: %.2f" % standard_deviation(@global_index/@count)
      end
    end

    pdf.move_down pdf.font_size
  end

  def prepare_question_rates(pdf, project)
    question_rates = []
    questions = {}

    question_rates << [I18n.t('activerecord.models.question'), I18n.t('projects.global_attitudinal_index_title'),
      I18n.t('projects.standard_deviation')
    ]

    if project.questions.present?
      questions = project.questions
    else
      project.teaching_units.each do |t_u|
        if questions.empty?
          questions = t_u.questions
        else
          questions << t_u.questions
        end
      end
    end

    questions.each do |q|
      index_by_question = 0
      total = 0

      project.project_instances.each do |p_i|
        p_i.question_instances.each do |q_i|
          if q_i.question_text.eql? "[#{q.code}] #{q.question}"
            if q_i.attitudinal_assessment_average
              index_by_question += q_i.attitudinal_assessment_average
              total += 1
            end
          end
        end
      end

      unless total == 0
        if index_by_question.round(2).zero?
          index_by_question = index_by_question.abs
        end

        question_rates << [q.code, '%.2f' % (index_by_question/total),
          '%.2f' % q.standard_deviation(project, index_by_question/total)
        ]
      end
    end

    pdf.move_down pdf.font_size
    pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
      pdf.text I18n.t 'projects.attitudinal_index_by_question_title'
    end
    pdf.move_down pdf.font_size

    add_pdf_table(pdf, question_rates)

    pdf.text I18n.t('projects.average_by_question',
      count: project.project_instances.count)
  end

  def standard_deviation_by_answer_type(average, category)
    summation = 0
    n = 0
    self.project_instances.each do |instance|
      instance.question_instances.each do |question|
        question.answer_instances.each do |answer|
          if answer.answer_category == category
            if attitudinal_assessment = answer.calculate_attitudinal_assessment
              summation += (attitudinal_assessment - average) ** 2
              n += 1
            end
          end
        end
      end
    end

    if n > 1
      Math.sqrt(summation.abs / (n - 1))
    else
      0
    end
  end

  def add_pdf_table(pdf, data)
    pdf.table(data) do
      row(0).style(
        :background_color => 'cccccc',
        :padding => [(PDF_FONT_SIZE * 0.5).round, (PDF_FONT_SIZE * 0.3).round]
      )
    end

    pdf.move_down pdf.font_size
  end
end
