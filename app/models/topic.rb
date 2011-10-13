class Topic < ActiveRecord::Base
  has_many :subtopic
  
  validates :title, :presence => true
end
