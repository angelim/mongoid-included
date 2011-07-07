class Invoice::Item
  include Mongoid::Document
  
  field :name  
  field :test, :default => "ale"
  field :test1, :default => "ale"
  

  validates_presence_of :name
end