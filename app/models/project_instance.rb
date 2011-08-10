class ProjectInstance < ActiveRecord::Base
  serialize :forms, Array
  serialize :profession_certification, Array
  serialize :profession_ocuppation, Array
  # Relaciones
  belongs_to :project
  has_many :question_instances, :dependent => :destroy
  accepts_nested_attributes_for :question_instances
  
  
  # Constantes
  TYPES = {
    :manual => 0,
    :interactive => 1
  }
  
  SOCIODEMOGRAPHIC_FORMS = [
    'country',
    'age',
    'genre',
    'student',
    'teacher',
    'teacher_level',
    'degree',
    'profession'
  ]
  
  # Restricciones
  validates :email, :age, :degree, :genre, :student_status, :teacher_status,
    :teacher_level, :profession_certification, :profession_ocuppation,
    :presence => true, :length => { :maximum => 255 }
  validates_numericality_of :age, :only_integer => true, :allow_nil => true,
    :allow_blank => true
  validates_uniqueness_of :email, :scope => :project_id, :allow_nil => true, :allow_blank => true
  validates :email, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, 
    :allow_blank => true, :allow_nil => true    
  validates_length_of :first_name, :last_name, :email, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end
  validates_each :profession_certification do |record, attr, value|
    unless (value || []).all? { |value| PROFESSIONS.include?(value.to_sym) }
      record.errors.add attr, :inclusion
    end
  end
  validates_each :profession_ocuppation do |record, attr, value|
    unless (value || []).all? { |value| PROFESSIONS.include?(value.to_sym) }
      record.errors.add attr, :inclusion
    end
  end
  
  def initialize(attributes = nil)
    super(attributes)
    
    if self.project
      self.forms = self.project.forms
      self.name = self.project.name
      self.identifier = self.project.identifier
      self.description = self.project.description
      self.year = self.project.year
      self.project_type = self.project.project_type
      self.valid_until = self.project.valid_until
      self.project.questions.each do |question|
        unless self.question_instances.detect {|qi| qi.question_id == question.id}
          self.question_instances.build(
            :question => question,
            :question_text => "[#{question.code}] #{question.question}"
          )
        end
      end
    end
  end
  
  def project_type_text
    I18n.t :"projects.#{TYPES.invert[self.project_type]}_type"
  end
  
  TYPES.each do |type, value|
    define_method(:"#{type}?") do
      self.project_type == value
    end
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

    pdf.text I18n.t(:presentation_text, :scope => i18n_scope)
    pdf.move_down pdf.font_size

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
      :position => :center,
      :width => pdf.margin_box.width,
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

    

    pdf.start_new_page
    pdf.text I18n.t(:questions_warning, :scope => i18n_scope), :style => :bold,
      :align => :center
    pdf.move_down(pdf.font_size)

    self.question_instances.each do |question|
      letter = 'A'

      pdf.font_size((PDF_FONT_SIZE * 0.75).round) do
        pdf.move_down(pdf.font_size)
        pdf.text "#{question.code} #{question.question}", :style => :bold_italic

        question.answer_instances.each do |answer|
          unless answer.clarification.blank?
            pdf.text answer.clarification
          end

          pdf.text "[__] #{letter}. #{answer.answer}",
            :indent_paragraphs => pdf.font_size

          letter.next!
        end
      end
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

  def add_country_form(pdf)
    countries = []
    i18n_scope = [:projects, :questionnaire, :country, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :country])

    COUNTRIES.each_with_index do |country, i|
      countries << "#{I18n.t(country, :scope => i18n_scope)} #{i+1} [__]"
    end

    pdf.text "#{question} #{countries.join('  ')}"
  end

  def add_degree_form(pdf)
    degrees = []
    i18n_scope = [:projects, :questionnaire, :degree, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree])

    DEGREES.each_with_index do |degree, i|
      unless degree == DEGREES.last
        degrees << "#{I18n.t(degree, :scope => i18n_scope)} #{i+1} [__]"
      else
        degrees << "#{I18n.t(degree, :scope => i18n_scope)} #{i+1} ______________"
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
      genres << "#{I18n.t(genre, :scope => i18n_scope)} #{i+1} [__]"
    end

    pdf.text "#{question} #{genres.join('  ')}"
  end

  def add_profession_form(pdf)
    data = []
    i18n_scope = [:projects, :questionnaire, :profession, :options]

    PROFESSIONS.each_with_index do |profession, i|
      data << [I18n.t(profession, :scope => i18n_scope), "#{i+1} [__]",
        "#{i} [__]"]
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
        "#{I18n.t(student_status, :scope => i18n_scope)} #{i+1} [__]"
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
        "#{I18n.t(teacher_status, :scope => i18n_scope)} #{i+1} [__]"
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
        "#{I18n.t(teacher_level, :scope => i18n_scope)} #{i+1} [__]"
    end

    pdf.text "#{question} #{teacher_levels.join('  ')}"
  end
  
end
