class Invoice
  includes_many :items
  includes_one :user, :inverse_of => :invoice, :index => true
end

class Invoice::Item
  included_in :invoice
end

class Invoice::User
  included_in :invoice, :inverse_of => :user
end