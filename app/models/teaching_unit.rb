class TeachingUnit < ActiveRecord::Base
  has_and_belongs_to_many :questions
  belongs_to :subtopic
  
  validates :title, :presence => true
end
