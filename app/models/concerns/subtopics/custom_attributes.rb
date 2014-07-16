module Subtopics::CustomAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :nested_teaching_unit

    alias_attribute :label, :title
  end
end
