class Invoice
  includes_many :items
  includes_one :user, :inverse_of => :invoice
  includes_one :other_user, :class_name => "Invoice::User", :inverse_of => :user_invoice
  includes_many :other_items, :class_name => "Invoice::Item"
end

class Invoice::Item
  included_in :invoice, :inverse_of => :items
  included_in :invoiced_by, :class_name => "Invoice", :inverse_of => :other_items
end

class Invoice::User
  included_in :invoice, :inverse_of => :user
  included_in :user_invoice, :class_name => "Invoice", :inverse_of => :other_user
end