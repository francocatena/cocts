class AnswerInstance < ApplicationModel
  include AnswerInstances::Scopes
  include AnswerInstances::Relations
  include AnswerInstances::Validations
  include AnswerInstances::Rates
end
