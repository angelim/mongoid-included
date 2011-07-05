# test methods
# test from_mirror
require 'spec_helper'

describe Invoice do
  let(:invoice) { Invoice.create(:title => "InvoiceTest") }
  
  it "respond to items" do
    invoice.should respond_to(:items)
  end
  
  it "has proxy to items" do
    invoice.items.create(:name => "ItemTest")
    invoice.items.should have(1).item
  end
end
