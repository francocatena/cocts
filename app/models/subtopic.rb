class Subtopic < ActiveRecord::Base
  attr_accessor :nested_teaching_unit
  
  alias_attribute :label, :title
  
  belongs_to :topic
  has_many :teaching_units
  
  
  validates :title, :presence => true
  validates_numericality_of :code, :only_integer => true, :allow_nil => true,
    :allow_blank => true
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)
    self.teaching_units ||= TeachingUnit.new
  end
  
  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }
    
    super(default_options.merge(options || {}))
  end
end
