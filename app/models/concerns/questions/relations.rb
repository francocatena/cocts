module Questions::Relations
  extend ActiveSupport::Concern

  included do
    has_many :answers, -> {
      order("#{Answer.table_name}.order ASC")
     }, dependent: :destroy
    has_and_belongs_to_many :teaching_units
    has_and_belongs_to_many :projects
  end
end
