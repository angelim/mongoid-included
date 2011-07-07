class Invoice
  include Mongoid::Document

  field :title  
  validates_presence_of :title
end
