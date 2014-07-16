module AnswerInstances::Rates
  extend ActiveSupport::Concern

  included do
    def calculate_attitudinal_assessment
      self.attitudinal_assessment = ['E', 'S'].include?(self.valuation) ? nil :
        CORRESPONDENCE_WITH_NORMALIZED_INDEX[self.answer_category][self.valuation.to_i]
    end
  end
end
