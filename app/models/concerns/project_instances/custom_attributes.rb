module ProjectInstances::CustomAttributes
  extend ActiveSupport::Concern

  included do
    serialize :forms, Array

    attr_accessor :manual_degree, :manual_degree_university
  end
end
