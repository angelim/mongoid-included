class Invoice::Item
  include Mongoid::Document
  include Mongoid::DocumentInclusion
  
  field :name  
  field :test, :default => "ale"
  field :test1, :default => "ale"
  

  validates_presence_of :name
end