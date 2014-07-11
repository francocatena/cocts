module ProjectInstances::Validations
  extend ActiveSupport::Concern

  included do
    validates :first_name, :presence => true
    validates_numericality_of :age, :only_integer => true, :allow_nil => true,
      :allow_blank => true
    validates_uniqueness_of :first_name, :scope => :project_id, :allow_nil => true, :allow_blank => true
    validates_length_of :professor_name, :first_name, :maximum => 255, :allow_nil => true,
      :allow_blank => true
    validates_each :forms do |record, attr, value|
      unless (value || []).all? { |value| SOCIODEMOGRAPHIC_FORMS.include?(value) }
        record.errors.add attr, :inclusion
      end
    end
  end
end
