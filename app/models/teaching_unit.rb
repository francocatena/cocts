class TeachingUnit < ApplicationModel
  attr_accessor :nested_question
  
  alias_attribute :label, :title
  
  has_and_belongs_to_many :questions
  has_and_belongs_to_many :projects
  belongs_to :subtopic
  
  validates :title, :presence => true
  validates_uniqueness_of :title
  
  validates_each :questions do |record, attr, value|
    if value.empty?
      record.errors.add attr, :blank
    end
  end
  
  def initialize(attributes = nil, options = {})
    super(attributes, options)
  end
  
  def as_json(options = nil)
    default_options = { :only => [:id], :methods => [:label] }
    
    super(default_options.merge(options || {}))
  end
  
  def self.full_text(query_terms)
    options = text_query(query_terms, 'title')
    conditions = [options[:query]]
    parameters = options[:parameters]
    
    where(
      conditions.map { |c| "(#{c})" }.join(' OR '), parameters
    ).order(options[:order])
  end
  
end
