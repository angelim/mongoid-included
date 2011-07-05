# test methods
# test from_mirror
require 'spec_helper'

describe Invoice::Item do
  let(:invoice) { Invoice.create(:title => "InvoiceTest") }
  let(:item) { invoice.items.create(:name => "ItemTest") }
  
  it "respond to invoice" do
    item.should respond_to(:invoice)
  end
  
  it "has proxy to invoice" do
    item.invoice.should == invoice
  end
end