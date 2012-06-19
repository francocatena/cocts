class ProjectInstance < ApplicationModel
  serialize :forms, Array
  
  # Atributos no persistentes
  attr_accessor :manual_degree, :manual_degree_university
  
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
  validates :first_name, :presence => true, :length => { :maximum => 255 }
  validates_numericality_of :age, :only_integer => true, :allow_nil => true,
    :allow_blank => true
  validates_uniqueness_of :first_name, :scope => :project_id, :allow_nil => true, :allow_blank => true
  validates_length_of :professor_name, :maximum => 255, :allow_nil => true,
    :allow_blank => true
  validates_each :forms do |record, attr, value|
    unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
      record.errors.add attr, :inclusion
    end
  end
    
  def initialize(attributes = nil, options = {})
    super(attributes, options)
    
    if self.project
      self.forms = self.project.forms
      self.name = self.project.name
      self.identifier = self.project.identifier
      self.group_type = self.project.group_type
      self.group_name = self.project.group_name
      self.description = self.project.description
      self.year = self.project.year
      self.project_type = self.project.project_type
      self.valid_until = self.project.valid_until
      if self.project.teaching_units.empty?
        self.project.questions.each do |question|
          unless self.question_instances.detect {|qi| qi.question_id == question.id}
            self.question_instances.build(
              :question => question,
              :question_text => "[#{question.code}] #{question.question}"
            )
          end
        end
      else
        self.project.teaching_units.each do |teaching_unit|
          teaching_unit.questions.each do |question|
            unless self.question_instances.detect {|qi| qi.question_id == question.id}
              self.question_instances.build(
                :question => question,
                :question_text => "[#{question.code}] #{question.question}"
              )
            end
          end
        end
      end
    end
    
    self.degree = self.manual_degree if self.manual_degree.present?
    self.degree_university = self.manual_degree_university if self.manual_degree_university.present?
  end
  
  def project_type_text
    I18n.t :"projects.#{TYPES.invert[self.project_type]}_type"
  end
  
  TYPES.each do |type, value|
    define_method(:"#{type}?") do
      self.project_type == value
    end
  end
  
  def calculate_attitudinal_rates
    calculate_attitudinal_assessment
    self.plausible_attitude_index = calculate_attitudinal_index(1)
    self.naive_attitude_index = calculate_attitudinal_index(0)
    self.adecuate_attitude_index = calculate_attitudinal_index(2) 
        
  end
  
  def calculate_attitudinal_assessment
    self.question_instances.each do |qi|
      qi.answer_instances.each do |ai|
        ai.calculate_attitudinal_assessment
      end
    end
  end
  
  def calculate_attitudinal_index(category)
    total = 0
    index = 0
    self.question_instances.each do |qi|
      qi.answer_instances.each do |ai|
        if ai.answer_category == category
          index+= ai.attitudinal_assessment
          total+= 1
        end
      end
    end
    if total == 0
      0
    else
      (index/total).round 2
    end
  end
  
  def attitudinal_global_index
    ((self.plausible_attitude_index + self.naive_attitude_index + self.adecuate_attitude_index) / 3).round 2
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
    group_name = I18n.t(:group_name, :scope => [:activerecord, :attributes, :project_instance])
    group_type = I18n.t(:group_type, :scope => [:activerecord, :attributes, :project_instance])
    pdf.move_down(pdf.font_size)
    pdf.text "["+self.identifier+"] " + self.name
    pdf.text description +": "+ self.description
    if self.year.present?
      pdf.text year +": "+ self.year.to_s
    end
    pdf.text valid_until +": "+ self.valid_until.to_formatted_s(:db)
    if self.group_name
      pdf.text group_name +": "+ self.group_name
    end
    if self.group_type
      pdf.text group_type +": "+ self.group_type
    end
        
          
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
  
  def add_name(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :name])
    
    pdf.text "#{question} #{self.first_name}"
  end
  
  def add_professor_name(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :professor_name])
    
    pdf.text "#{question} #{self.professor_name}"
  end

  def add_age(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :age])
    pdf.text "#{question} #{self.age}"
  end
  
  def add_educational_center_name(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :educational_center_name])
    
    pdf.text "#{question} #{self.educational_center_name}"
  end
  
  def add_educational_center_city(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :educational_center_city])
    
    pdf.text "#{question} #{self.educational_center_city}"
  end
      
  def add_study_subjects_different(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :study_subjects_different])
    
    pdf.text "#{question} #{self.study_subjects_different}"
  end
  
  def add_degree_school(pdf)
   i18n_scope = [:projects, :sociodemographic_forms, :degree_school]
   question = I18n.t(:question, :scope => i18n_scope)
   i18n_scope = [:projects, :sociodemographic_forms, :degree_school, :options]
   pdf.text I18n.t(:'projects.sociodemographic_forms.degrees.question')
   pdf.move_down(pdf.font_size)
   pdf.text "#{question}: #{I18n.t(self.degree_school, :scope => i18n_scope)}",
     :indent_paragraphs => 10
  end
  
  def add_degree_university(pdf)
    i18n_scope = [:projects, :sociodemographic_forms, :degree_university, :options]
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :degree_university])
    pdf.text "#{question}: #{I18n.t(self.degree_university, :scope => i18n_scope)}",
     :indent_paragraphs => 10
  end
  
  def add_study_subjects(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :study_subjects])
    
    pdf.text "#{question} #{self.study_subjects}"
  end
  
  def add_study_subjects_choose(pdf)
    question = I18n.t(:question,
      :scope => [:projects, :sociodemographic_forms, :study_subjects_choose])

    pdf.text "#{question} #{I18n.t(self.study_subjects_choose, :scope => 
    [:projects, :sociodemographic_forms, :study_subjects_choose, :options]) }"
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
    if self.teacher_level.present?
      question = I18n.t(:question,
        :scope => [:projects, :sociodemographic_forms, :teacher_level])
      teacher_level = I18n.t(self.teacher_level, :scope => [:projects, :questionnaire, 
          :teacher_level, :options])
      pdf.text question +" "+ teacher_level
    end
  end
  
end
