module Answers::Validations
  extend ActiveSupport::Concern

  included do
    validates :answer, :category, :order, :presence => true
    validates_numericality_of :order, :category, :only_integer => true,
      :allow_nil => true, :allow_blank => true
    validates_inclusion_of :category, :in => CATEGORIES.values,
      :allow_nil => true, :allow_blank => true
  end
end
