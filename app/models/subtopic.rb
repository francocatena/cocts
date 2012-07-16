class Subtopic < ApplicationModel
  attr_accessor :nested_teaching_unit

  alias_attribute :label, :title

  belongs_to :topic
  has_many :teaching_units

  validates :title, :code, :presence => true
  validates_uniqueness_of :title
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

  def self.search(search, page)
    order = order("#{Subtopic.table_name}.code ASC")
    if search
      where('title ILIKE :t OR code = :c', :t => "%#{search}%", :c => search.to_i).order.paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    else
      scoped.order.paginate(
        :page => page,
        :per_page => APP_LINES_PER_PAGE
      )
    end
  end
end
