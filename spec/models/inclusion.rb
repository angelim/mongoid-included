class Invoice
  includes_many :items
  includes_one :user
end

class Invoice::Item
  included_in :invoice
end

class Invoice::User
  included_in :invoice
end