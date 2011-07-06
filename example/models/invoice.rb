class Invoice
  include Mongoid::Document
  include Mongoid::DocumentInclusion
  field :title
  
  includes_many :items
  includes_one :user
end
