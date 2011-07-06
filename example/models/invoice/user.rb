class Invoice::User
  include Mongoid::Document
  include Mongoid::DocumentInclusion
  
  field :name  
  
  included_in :invoice
end