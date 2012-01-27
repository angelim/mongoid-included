class Invoice::PriceList
  include Mongoid::Document
  
  field :value, :type => Float
end