class Topic < ActiveRecord::Base
  attr_accessor :nested_subtopic
  
  has_many :subtopics
  
  validates :title, :presence => true
end
