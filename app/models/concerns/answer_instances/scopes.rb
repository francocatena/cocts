module AnswerInstances::Scopes
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order("position") }
  end
end
