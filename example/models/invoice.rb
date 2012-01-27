class Invoice
  include Mongoid::Document
  field :title
  
  includes_many :items
  includes_one :user
end
