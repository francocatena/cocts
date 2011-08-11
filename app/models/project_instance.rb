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
    
    # Datos proyecto
    pdf.move_down(pdf.font_size)
    pdf.text I18n.t(:'projects.questionnaire.project_data_title').gsub(/\*/, ''),
        :style => :bold
    description = I18n.t(:description, :scope => [:activerecord, :attributes, :project_instance])
    year = I18n.t(:year, :scope => [:activerecord, :attributes, :project_instance])
    valid_until = I18n.t(:valid_until, :scope => [:activerecord, :attributes, :project_instance])
    pdf.move_down(pdf.font_size)
    pdf.text "["+self.identifier+"] " + self.name
    pdf.text description +": "+ self.description
    if self.year.present?
      pdf.text year +": "+ self.year.to_s
    end
    pdf.text valid_until +": "+ self.valid_until.to_formatted_s(:db)
        
    # Datos personales
    pdf.move_down(pdf.font_size)
    pdf.text I18n.t(:'projects.questionnaire.personal_data_title').gsub(/\*/, ''),
        :style => :bold
    pdf.move_down(pdf.font_size)
    if self.first_name.present?
      name = I18n.t(:first_name, :scope => [:activerecord, :attributes, :project_instance])
      pdf.text name+": "+ self.first_name
    end 
    if self.last_name.present?
      name = I18n.t(:last_name, :scope => [:activerecord, :attributes, :project_instance])
      pdf.text name +": "+ self.last_name
    end
    email = I18n.t(:email, :scope => [:activerecord, :attributes, :project_instance])
    pdf.text email +": "+ self.email
      
    # Datos sociodemográficos
    unless self.forms.empty?
      i18n_scope.slice!(-2, 2)
      pdf.move_down(pdf.font_size)
      pdf.text I18n.t(:'projects.questionnaire.sociodemographic_forms_title_instance').gsub(/\*/, ''),
        :style => :bold

      self.forms.each do |form|
        pdf.font_size((PDF_FONT_SIZE * 0.8).round) do
          pdf.move_down(pdf.font_size)

          self.send(:"add_#{form}", pdf)
        end
      end
    end

    pdf.start_new_page
    pdf.text I18n.t(:'projects.questionnaire.question_instance_title').gsub(/\*/, ''),
      :style => :bold, :align => :center
    pdf.move_down(pdf.font_size)

    self.question_instances.each do |question|
      letter = 'A'

      pdf.font_size((PDF_FONT_SIZE * 1).round) do
        pdf.move_down(pdf.font_size)
        pdf.text "#{question.question_text}", :style => :bold_italic

        question.answer_instances.each do |answer|
          pdf.text "[#{answer.valuation}] #{letter}. #{answer.answer_text}",
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

  def add_age(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :age])
    pdf.text "#{question} #{self.age}"
  end

  def add_country(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :country])
    pdf.text "#{question} #{self.country}"
  end

  def add_degree(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree])
    degree = I18n.t(self.degree, :scope => [:projects, :questionnaire, :degree,
        :options])
    pdf.text question +" "+ degree
  end

  def add_genre(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :genre])
    genre = I18n.t(self.genre, :scope => [:projects, :questionnaire, :genre, :options])
    pdf.text question +" "+ genre
  end

  def add_profession(pdf)
    data = []
    i18n_scope = [:projects, :questionnaire, :profession, :options]

    PROFESSIONS.each_with_index do |profession, i|
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
      },
      :column_height => 2
  end

  def add_student(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :student])
    student = I18n.t(self.student_status, :scope => [:projects, :questionnaire, 
        :student, :options])
    pdf.text question +" "+ student
  end

  def add_teacher(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :teacher])
    teacher = I18n.t(self.teacher_status, :scope => [:projects, :questionnaire, 
        :teacher, :options])
    pdf.text question +" "+ teacher
  end

  def add_teacher_level(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :teacher_level])
    teacher_level = I18n.t(self.teacher_level, :scope => [:projects, :questionnaire, 
        :teacher_level, :options])
    pdf.text question +" "+ teacher_level
  end
  
end
