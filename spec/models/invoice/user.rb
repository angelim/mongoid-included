class Invoice::User
  include Mongoid::Document
  include Mongoid::DocumentInclusion
  
  field :name
end