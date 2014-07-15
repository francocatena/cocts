class Answer < ApplicationModel
  include Answers::Validations
  include Answers::Relations
  include Answers::Rates

  def ==(other)
    if other.kind_of?(Answer)
      if other.new_record?
        other.object_id == self.object_id
      else
        other.id == self.id
      end
    end
  end

  def category_text(short = false)
    type = short ? :shor_type : :long_type

    I18n.t :"projects.answers.#{type}.#{CATEGORIES.invert[self.category]}"
  end
end
