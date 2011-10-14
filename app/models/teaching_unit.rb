class TeachingUnit < ActiveRecord::Base
  attr_accessor :nested_question
  
  alias_attribute :label, :title
  
  has_and_belongs_to_many :questions
  has_and_belongs_to_many :projects
  belongs_to :subtopic
  
  validates :title, :presence => true
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)
  end
  
  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }
    
    super(default_options.merge(options || {}))
  end
  
end
