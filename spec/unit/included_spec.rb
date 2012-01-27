require 'spec_helper'

describe "Child Model" do
  context "when being included" do
    it "strips namespace from #param_key" do
      Invoice::Item.model_name.param_key.should == "item"
    end
  
    it "strips namespace from #route_key" do
      Invoice::Item.model_name.route_key.should == "items"
    end
    context "when pluralizing partial path" do
      it "returns partial path with pluralized embedding class" do
        Invoice::Item.new.to_partial_path.should == "invoices/items/item"
      end
    end
    context "when skipping partial path pluralization" do
      it "returns partial path with singular embedding class" do
        Invoice::PriceList.new.to_partial_path.should == "invoice/price_lists/price_list"
      end
    end
    
    it "delegates options to mongoid relation macro" do
      Invoice::User.relations["invoice"].inverse_of.should == :user
    end

    it "is embedded in parent class" do
      Invoice::Item.relations.keys.should include "invoice"
      Invoice::Item.relations["invoice"].macro.should == :embedded_in
    end
    it "#includded_in returns parent model" do
      Invoice::Item.included_by.should include Invoice
    end
    it "forbids inclusion in another parent" do
      Object.const_set "AnotherDocument", Class.new
      AnotherDocument.send(:include, Mongoid::Document)
      expect { Invoice::Item.included_in :another_document }.
      to raise_error Mongoid::DocumentInclusion::DocumentAlreadyIncluded, /Document already included/
    end
    context "when included with custom relation name" do
      it "returns relation name" do
        Invoice::Item.relations["invoiced_by"].macro.should == :embedded_in
      end
      it "returns relation class" do
        Invoice::Item.relations["invoiced_by"].class_name.should == "Invoice"
      end
      
      
    end
  end
  
  context "when not included" do
    it "should preserve original name" do
      Invoice::NotIncluded.model_name.should == "Invoice::NotIncluded"
    end
  end
  
  it "issues an error if parent is not mongoid document" do
    Object.const_set "NonMongoidDocument", Class.new
    NonMongoidDocument.const_set "NonMongoidChild", Class.new
    NonMongoidDocument::NonMongoidChild.send(:include, Mongoid::Document)
    NonMongoidDocument::NonMongoidChild.send(:include, Mongoid::DocumentInclusion)
    expect { NonMongoidDocument::NonMongoidChild.included_in :invoice }.
    to raise_error(Mongoid::DocumentInclusion::NotMongoidDocument, /Parent must be Mongoid::Document/)
  end
  

end

