class Invoice
  include Mongoid::Document
  include Mongoid::DocumentInclusion
  field :title  
  validates_presence_of :title
end
