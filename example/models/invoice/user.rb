class Invoice::User
  include Mongoid::Document
  
  field :name  
  
  included_in :invoice
end