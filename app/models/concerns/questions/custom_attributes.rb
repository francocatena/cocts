module Questions::CustomAttributes
  extend ActiveSupport::Concern

  included do
    alias_attribute :informal, :question
    alias_attribute :label, :code

    accepts_nested_attributes_for :answers, allow_destroy: true
  end
end
