module Answers::Relations
  extend ActiveSupport::Concern

  included do
    belongs_to :question
  end
end
