module Projects::CustomAttributes
  extend ActiveSupport::Concern

  included do
    serialize :forms, Array

    attr_accessor :nested_question
    attr_accessor :nested_teaching_unit
  end
end
