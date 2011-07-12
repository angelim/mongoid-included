class Invoice
  includes_many :items
  includes_one :user, :inverse_of => :invoice, :index => true
  includes_many :other_items, :class_name => "Invoice::Item", :skip_validation => true
end

class Invoice::Item
  included_in :invoice, :inverse_of => :items
  included_in :invoice, :inverse_of => :other_items
end

class Invoice::User
  included_in :invoice, :inverse_of => :user
end