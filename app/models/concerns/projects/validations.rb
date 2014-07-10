module Projects::Validations
  extend ActiveSupport::Concern

  included do
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
    validate :questions_xor_teaching_units
    validates_each :forms do |record, attr, value|
      unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
        record.errors.add attr, :inclusion
      end
    end
  end

  private

    def questions_xor_teaching_units
      if !(questions.blank? ^ teaching_units.blank?)
        self.errors[:question_ids] << t('projects.empty_questions_error')
      end
    end
end
