# -*- coding: utf-8 -*-
class Project < ApplicationModel
  serialize :forms, Array
  # Scopes
  default_scope { order('name') }

  # Atributos no persistentes
  attr_accessor :nested_question
  attr_accessor :nested_teaching_unit

  # Constantes
  TYPES = {
    :manual => 0,
    :interactive => 1
  }

  SOCIODEMOGRAPHIC_FORMS = [
    'name',
    'professor_name',
    'country',
    'age',
    'genre',
    'degree_school',
    'degree_university',
    'study_subjects_different',
    'study_subjects',
    'study_subjects_choose',
    'educational_center_name',
    'educational_center_city'
  ]

  # Restricciones
  validates :name, :test_type, :group_name, :group_type, :description, :valid_until,
    :presence => true
  validates_uniqueness_of :identifier, :allow_nil => true, :allow_blank => true
  validates_numericality_of :year, :only_integer => true, :allow_nil => true,
    :allow_blank => true, :greater_than => 1000, :less_than => 3000
  validates_length_of :name, :identifier, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates :identifier, :exclusion => { :in => %w(admin ayuda help) }
  validates_date :valid_until, :on_or_after => lambda { Date.today },
    :allow_nil => false, :allow_blank => false, :if => :interactive?
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end

  # Relaciones
  has_and_belongs_to_many :questions, :validate => false
  has_and_belongs_to_many :teaching_units, -> { uniq }, :validate => false
  has_many :project_instances
  belongs_to :user

  # Callbacks
  before_destroy :can_be_destroyed?

  def initialize(attributes = nil, options = {})
    super(attributes, options)

    self.project_type ||= TYPES[:interactive]
    self.forms ||= SOCIODEMOGRAPHIC_FORMS
  end

  def is_valid?
    Time.now < self.valid_until
  end

  def to_param
    self.identifier
  end

  def can_be_destroyed?
    self.project_instances.blank?
  end

  TYPES.each do |type, value|
    define_method(:"#{type}?") do
      self.project_type == value
    end
  end

  def set_parent_data(project)
    self.name = project.name
    self.description = project.description
    self.valid_until = project.valid_until
    self.year = project.year
    self.forms = project.forms
    self.teaching_units = project.teaching_units
    self.questions = project.questions
  end

  def project_type_text
    I18n.t "projects.#{TYPES.invert[self.project_type]}_type"
  end

  def project_group_type_text
    I18n.t "projects.questionnaire.group_type.options.#{self.group_type}"
  end

  def short_test_type_text
    self.test_type[0..2]
  end

  def short_group_type_text
    self.group_type[0,1]
  end

  def project_test_type_text
    I18n.t "projects.questionnaire.test_type.options.#{self.test_type}"
  end

  def self.search(search, user, page)
    if search
      sql_search = where("#{Project.table_name}.name ILIKE :q OR #{Project.table_name}.identifier ILIKE :q", :q => "%#{search}%")
    else
      sql_search = all
    end
    if user.private
      sql_search.where('user_id = :id', :id => user.id).paginate(:page => page, :per_page => APP_LINES_PER_PAGE)
    else
      sql_search.paginate(:page => page, :per_page => APP_LINES_PER_PAGE )
    end
  end

  def generate_identifier
    "#{self.id}-#{self.short_group_type_text}-#{self.short_test_type_text}"
  end

  def generate_pdf_rates(projects, user)
    pdf = Prawn::Document.new(PDF_OPTIONS)
    pdf.font_size = PDF_FONT_SIZE
    # Fecha
    date = I18n.l(Date.today, :format => :long)
    name = "#{user.name} #{user.lastname}"
    pdf.font_size((PDF_FONT_SIZE * 0.7).round) do
      pdf.move_down pdf.font_size
      pdf.text "#{I18n.t 'labels.generated_on'} #{date} #{I18n.t 'labels.by'} #{name}", :align => :right
    end
    # Título
    pdf.font_size((PDF_FONT_SIZE * 1.6).round) do
      pdf.move_down pdf.font_size
      pdf.text "#{I18n.t('activerecord.models.project')} #{self.name}", :style => :bold,
        :align => :center
      pdf.move_down pdf.font_size
    end
    # UDs
    questions = ""
    if self.teaching_units.present?
      pdf.font_size((PDF_FONT_SIZE * 1.4).round) do
        pdf.move_down pdf.font_size
        pdf.text I18n.t('actioncontroller.teaching_units')
        pdf.move_down pdf.font_size
      end
      self.teaching_units.each do |unit|
        unit.questions.each do |question|
          questions += " #{question.code} "
        end
        pdf.font_size((PDF_FONT_SIZE * 1.1).round) do
          pdf.text "#{unit.title} (#{questions})"
          pdf.move_down pdf.font_size
        end
      end
    # Cuestiones
    else
      pdf.font_size((PDF_FONT_SIZE * 1.4).round) do
        self.questions.each do |question|
          questions += " #{question.code} "
        end
        pdf.move_down pdf.font_size
        pdf.text "#{I18n.t('actioncontroller.questions')}: #{questions}"
        pdf.move_down pdf.font_size
      end
    end

    pdf.font_size((PDF_FONT_SIZE * 1.4).round) do
      pdf.move_down pdf.font_size
      pdf.text I18n.t('projects.attitudinal_index_title')
      pdf.move_down pdf.font_size
    end
    data = []

    projects.each do |project|
      if project.project_instances.present?
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

        data[0] = [I18n.t('projects.alumn_title'), I18n.t('projects.global_attitudinal_index_title'), I18n.t('projects.standard_deviation')]

        adecuate_index = plausible_index = naive_index = global_index = 0

        count = attitudinal_assessments = answers = 0

        professors = []
        project.project_instances.each_with_index do |instance, i|
          if professors.exclude?(instance.professor_name.try(:titleize)) && instance.professor_name
            professors << instance.professor_name.titleize
          end
          alumn_assessments = 0
          alumn_answers = 0
          instance.calculate_attitudinal_rates
          attitudinal_global_index = instance.attitudinal_global_index

          adecuate_index += instance.adecuate_attitude_index
          plausible_index += instance.plausible_attitude_index
          naive_index += instance.naive_attitude_index
          global_index += instance.attitudinal_global_index

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
            count += 1
            data[count] = [instance.student_data, '%.2f' % average_assessments,
              '%.2f' % instance.standard_deviation(average_assessments)
            ]
          end
        end

        if professors.present?
          pdf.text I18n.t('activerecord.attributes.project_instance.professor_name') + ': ' + professors.join(', ')
          pdf.move_down pdf.font_size
        end

        add_pdf_table(pdf, data)

        unless answers == 0
          pdf.text "#{I18n.t('projects.global_attitudinal_index_title')}: #{'%.2f' % (attitudinal_assessments / answers)}"
        end

        data.clear

        # Attitudinal index by question
        data[0] = [I18n.t('activerecord.models.question'), I18n.t('projects.global_attitudinal_index_title'),
          I18n.t('projects.standard_deviation')
        ]
        questions = {}

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
        index = 0
        questions.each do |q|
          index += 1
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

            data[index] = [q.code, '%.2f' % (index_by_question/total),
              '%.2f' % q.standard_deviation(project, index_by_question/total)
            ]
          end
        end

        pdf.move_down pdf.font_size
        pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
          pdf.text I18n.t 'projects.attitudinal_index_by_question_title'
        end
        pdf.move_down pdf.font_size

        add_pdf_table(pdf, data)

        data.clear

        pdf.text "Media de los #{project.project_instances.count} individuos por cuestión"

        pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
          pdf.move_down pdf.font_size
          pdf.text I18n.t('projects.attitudinal_index_by_category_title')
          pdf.move_down pdf.font_size
        end

        unless count == 0
          data << [I18n.t('activerecord.attributes.answer.category'), I18n.t('projects.attitudinal_index_title'),
            I18n.t('projects.standard_deviation')
          ]
          data << [I18n.t('questions.answers.long_type.adecuate'), '%.2f' % (adecuate_index/count),
            '%.2f' % standard_deviation_by_answer_type(adecuate_index/count, 2)]
          data << [I18n.t('questions.answers.long_type.plausible'), '%.2f' % (plausible_index/count),
            '%.2f' % standard_deviation_by_answer_type(plausible_index/count, 1)]
          data << [I18n.t('questions.answers.long_type.naive'), '%.2f' % (naive_index/count),
            '%.2f' % standard_deviation_by_answer_type(naive_index/count, 0)]

          add_pdf_table(pdf, data)
          data.clear

          pdf.font_size((PDF_FONT_SIZE * 1.2).round) do
            pdf.move_down pdf.font_size
            pdf.text "#{I18n.t 'projects.attitudinal_global_index'}: %.2f" % (global_index/count)
            pdf.move_down pdf.font_size
            pdf.text "#{I18n.t 'projects.standard_deviation'}: %.2f" % standard_deviation(global_index/count)
          end
        end
        pdf.move_down pdf.font_size
      end
    end

    # Numeración en pie de página
    pdf.page_count.times do |i|
      pdf.go_to_page(i+1)
      pdf.draw_text "#{i+1} / #{pdf.page_count}", :at=>[1,1], :size => (PDF_FONT_SIZE * 0.75).round
    end

    FileUtils.mkdir_p File.dirname(self.pdf_full_path)
    pdf.render_file self.pdf_full_path
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

  def to_pdf
    i18n_scope = [:projects, :questionnaire]
    pdf = Prawn::Document.new(PDF_OPTIONS)
    pdf.font_size = PDF_FONT_SIZE

    # Presentación
    pdf.font_size((PDF_FONT_SIZE * 1.5).round) do
      pdf.text I18n.t(:presentation, :scope => i18n_scope), :style => :bold,
        :align => :center

      pdf.move_down pdf.font_size
    end

    pdf.font_size((PDF_FONT_SIZE * 0.85).round) do
      pdf.text I18n.t(:presentation_text, :scope => i18n_scope)
      pdf.move_down pdf.font_size
    end

    # Explicación de la escala
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

    i18n_scope.slice!(-1)

    pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
      pdf.move_down(pdf.font_size)
      pdf.text I18n.t(:scale_clarification, :scope => i18n_scope)
    end

    # Pregunta de ejemplo
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

    # Datos sociodemográficos
    unless self.forms.empty?
      i18n_scope.slice!(-2, 2)
      pdf.move_down(pdf.font_size)
      pdf.text I18n.t(:sociodemographic_forms_title,
        :scope => i18n_scope).gsub(/\*/, '')

      self.forms.each do |form|
        pdf.font_size((PDF_FONT_SIZE * 0.6).round) do
          pdf.move_down(pdf.font_size)

          self.send(:"add_#{form}_form", pdf)
        end
      end
    end
      pdf.start_new_page
      i18n_scope = [:projects, :questionnaire]
      pdf.text I18n.t(:questions_warning, :scope => i18n_scope), :style => :bold,
        :align => :center
      pdf.move_down(pdf.font_size)

   if self.teaching_units.empty?

      self.questions.each do |question|
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

   else
     self.teaching_units.each do |teaching_unit|
       subtopic = teaching_unit.subtopic
       topic = subtopic.try(:topic)

       pdf.move_down(pdf.font_size)
       pdf.text "#{I18n.t('activerecord.models.teaching_unit')}: #{teaching_unit.title}", :style => :bold_italic

       if subtopic.present? && topic.present?
           pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
           pdf.move_down(pdf.font_size)
           pdf.text "Tema: #{topic.code}- #{topic.title}"
           pdf.text "Subtema: #{subtopic.code}- #{subtopic.title}"
         end
       end
       teaching_unit.questions.each do |question|
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
     end
   end

    # Numeración en pie de página
    pdf.page_count.times do |i|
      pdf.go_to_page(i+1)
      pdf.draw_text "#{i+1} / #{pdf.page_count}", :at=>[1,1], :size => (PDF_FONT_SIZE * 0.75).round
    end

    FileUtils.mkdir_p File.dirname(self.pdf_full_path)

    pdf.render_file self.pdf_full_path
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

    pdf.text "#{question} #{countries.join('  ')}"
  end

  def add_degree_school_form(pdf)
    degrees = []
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree_school])
    i18n_scope = [:projects, :sociodemographic_forms, :degree_school, :options]

    DEGREES_SCHOOL.each do |degree|
      degrees << "#{I18n.t(:'projects.sociodemographic_forms.degree_school.courses')}:  [__] #{I18n.t(degree, :scope => i18n_scope)} "
    end

    pdf.text I18n.t(:'projects.sociodemographic_forms.degrees.question')
    pdf.move_down(pdf.font_size)
    pdf.text "#{question}:  #{degrees.join('  ')}", :indent_paragraphs => 10
  end

  def add_degree_university_form(pdf)
    degrees = []
    i18n_scope = [:projects, :sociodemographic_forms, :degree_university, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree_university])

    DEGREES_UNIVERSITY.each_with_index do |degree, i|
      unless degree == DEGREES.last
        degrees << "#{I18n.t(:'projects.sociodemographic_forms.degree_university.degrees')}:  [__] #{I18n.t(degree, :scope => i18n_scope)}"
      else
        degrees << "#{I18n.t(degree, :scope => i18n_scope)} ______________"
      end
    end

    pdf.text "#{question}:  #{degrees.join('  ')}", :indent_paragraphs => 10
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

    pdf.text "#{question} #{degrees.join('  ')}"
  end

  def add_genre_form(pdf)
    genres = []
    i18n_scope = [:projects, :questionnaire, :genre, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :genre])

    GENRES.each_with_index do |genre, i|
      genres << "[__] #{I18n.t(genre, :scope => i18n_scope)} "
    end

    pdf.text "#{question} #{genres.join('  ')}"
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

    pdf.text "#{question} #{student_statuses.join('  ')}"
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

    pdf.text "#{question} #{teacher_statuses.join('  ')}"
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

    pdf.text "#{question} #{teacher_levels.join('  ')}"
  end
end
