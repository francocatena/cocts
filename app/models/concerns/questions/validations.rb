module Questions::Validations
  extend ActiveSupport::Concern

  included do
    validates :code, :question, :dimension, presence: true
    validates_uniqueness_of :code, allow_blank: true, allow_nil: true
    validates_length_of :code, maximum: 255, allow_nil: true,
      allow_blank: true
    validates_format_of :code, with: /\A\d+\Z/,
      allow_blank: true, allow_nil: true
    validates_numericality_of :dimension, only_integer: true,
      allow_blank: true, allow_nil: true
    validates_inclusion_of :dimension, in: DIMENSIONS, allow_blank: true,
      allow_nil: true
  end
end
