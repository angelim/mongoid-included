class Invoice::Item
  include Mongoid::Document
  include Mongoid::DocumentInclusion
  
  field :description  
  
  included_in :invoice
end