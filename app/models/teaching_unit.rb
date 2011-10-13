class TeachingUnit < ActiveRecord::Base
  attr_accessor :nested_question
  
  has_and_belongs_to_many :questions
  belongs_to :subtopic
  
  validates :title, :presence => true
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)
  end
end
