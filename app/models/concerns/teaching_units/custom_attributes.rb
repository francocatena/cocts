module TeachingUnits::CustomAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessor :nested_question

    alias_attribute :label, :title
  end
end
