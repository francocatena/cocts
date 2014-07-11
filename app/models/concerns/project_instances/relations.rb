module ProjectInstances::Relations
  extend ActiveSupport::Concern

  included do
    belongs_to :project
    has_many :question_instances, :dependent => :destroy
    accepts_nested_attributes_for :question_instances
  end
end
