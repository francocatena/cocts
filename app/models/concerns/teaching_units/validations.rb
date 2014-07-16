module TeachingUnits::Validations
  extend ActiveSupport::Concern

  included do
    validates :title, presence: true
    validates :title, uniqueness: true

    validates_each :questions do |record, attr, value|
      record.errors.add attr, :blank if value.empty?
    end
  end
end
