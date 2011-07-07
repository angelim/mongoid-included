require 'spec_helper'

describe "Mongoid::Included" do

  describe "Parent Model" do
    
    let(:parent) { Invoice }
    
    it "delegates options to mongoid relation macro" do
      parent.relations["user"].inverse_of.should == :invoice
    end
    
    it "embeds many children with given association name" do
      parent.relations.keys.include? "items"
      parent.relations["items"].macro.should == :embeds_many
    end
    
    it "embeds one child with given association name" do
      parent.relations.keys.include? "item"
      parent.relations["user"].macro.should == :embeds_one
    end
    
    it "embeds child with given association class" do
      parent.relations["items"].class_name.should == "Invoice::Item"
    end
    
    it "issues an error if parent is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      NonMongoidDocument.const_set "NonMongoidEmbed", Class.new
      expect { NonMongoidDocument.includes_many :non_mongoid_embeds }.
      to raise_error(Mongoid::DocumentInclusion::NotMongoidDocument, /Parent document must include Mongoid::Document/)
    end
    
    it "issues an error if child is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.const_set "NonMongoidEmbed", Class.new
      NonMongoidDocument.send(:include, Mongoid::Document)
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      expect {NonMongoidDocument.includes_many :non_mongoid_embeds }.
      to raise_error(Mongoid::DocumentInclusion::NotMongoidDocument, /Child document must include Mongoid::Document/)
    end
  
  end
  
  context "when child class is included in parent" do
    
    it "delegates options to mongoid relation macro" do
      Invoice::User.relations["invoice"].inverse_of.should == :user
    end
    
    it "is embedded in parent class" do
      Invoice::Item.relations.keys.include? "invoice"
      Invoice::Item.relations["invoice"].macro.should == :embedded_in
    end
    
    it "issues an error if child is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.const_set "NonMongoidChild", Class.new
      NonMongoidDocument.send(:include, Mongoid::Document)
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      NonMongoidDocument::NonMongoidChild.send(:include, Mongoid::DocumentInclusion)
      expect { NonMongoidDocument::NonMongoidChild.included_in :invoice }.
      to raise_error(Mongoid::DocumentInclusion::NotMongoidDocument, /Child document must include Mongoid::Document/)
    end    
    
    it "issues an error if parent is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.const_set "NonMongoidChild", Class.new
      NonMongoidDocument::NonMongoidChild.send(:include, Mongoid::Document)
      NonMongoidDocument::NonMongoidChild.send(:include, Mongoid::DocumentInclusion)
      expect { NonMongoidDocument::NonMongoidChild.included_in :invoice }.
      to raise_error(Mongoid::DocumentInclusion::NotMongoidDocument, /Parent document must include Mongoid::Document/)
    end
    
    context "when overwriting #model_name" do
      it "strips namespace from #param_key" do
        Invoice::Item.model_name.param_key.should == "item"
      end
    
      it "strips namespace from #route_key" do
        Invoice::Item.model_name.route_key.should == "items"
      end
    
      it "pluralize namespace in #partial_path" do
        Invoice::Item.model_name.partial_path.should == "invoices/items/item"
      end
      
      it "should not override without #included_in" do
        Invoice::NotIncluded.model_name.should == "Invoice::NotIncluded"
      end
    end
    
    it "forbids inclusion in another parent" do
      expect { Invoice::Item.included_in :invoice }.to raise_error { Mongoid::DocumentInclusion::DocumentAlreadyIncluded }
    end
  end
  
end

