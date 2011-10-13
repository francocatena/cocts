class Subtopic < ActiveRecord::Base
  belongs_to :topic
  has_many :subtopic
  
  validates :title, :presence => true
end
