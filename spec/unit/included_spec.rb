require 'spec_helper'

describe "Child Model" do
  context "when being included" do
    it "strips namespace from #param_key" do
      Invoice::Item.model_name.param_key.should == "item"
    end
  
    it "strips namespace from #route_key" do
      Invoice::Item.model_name.route_key.should == "items"
    end
  
    it "pluralize namespace in #partial_path" do
      Invoice::Item.model_name.partial_path.should == "invoices/items/item"
    end
    
    it "delegates options to mongoid relation macro" do
      Invoice::User.relations["invoice"].inverse_of.should == :user
    end

    it "is embedded in parent class" do
      Invoice::Item.relations.keys.should include "invoice"
      Invoice::Item.relations["invoice"].macro.should == :embedded_in
    end
    it "#includded_in returns parent model" do
      Invoice::Item.included_by.should == :invoice
    end
    it "forbids inclusion in another parent" do
      expect { Invoice::Item.included_in :invoice }.
      to raise_error Mongoid::DocumentInclusion::DocumentAlreadyIncluded, /Document already included/
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

