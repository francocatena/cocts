class Subtopic < ActiveRecord::Base
  attr_accessor :nested_teaching_unit
  
  belongs_to :topic
  has_many :teaching_units
  
  
  validates :title, :presence => true
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)
    self.teaching_units ||= TeachingUnit.new
  end
end
