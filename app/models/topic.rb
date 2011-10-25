class Topic < ActiveRecord::Base
  attr_accessor :nested_subtopic
  
  has_many :subtopics, :dependent => :destroy
  
  validates :title, :code, :presence => true
  validates_uniqueness_of :title, :code
  validates_numericality_of :code, :only_integer => true, :allow_nil => true,
    :allow_blank => true
  
end
