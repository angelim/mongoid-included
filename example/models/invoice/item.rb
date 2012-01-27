class Invoice::Item
  include Mongoid::Document
  
  field :description  
  
  included_in :invoice
end