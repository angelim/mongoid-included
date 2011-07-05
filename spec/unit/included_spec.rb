require 'spec_helper'

describe "Mongoid::Included" do

  context "when parent class includes a child" do
    it "delegates options to mongoid relation macro" do
      Invoice.relations["user"].inverse_of.should == :invoice
    end
    
    it "embeds many children with given association name" do
      Invoice.relations.keys.include? "items"
      Invoice.relations["items"].macro.should == :embeds_many
    end
    
    it "embeds one child with given association name" do
      Invoice.relations.keys.include? "item"
      Invoice.relations["user"].macro.should == :embeds_one
    end
    
    it "embeds child with given association class" do
      Invoice.relations["items"].class_name.should == "Invoice::Item"
    end
    
    it "issues an error if not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      NonMongoidDocument.const_set "NonMongoidEmbed", Class.new
      begin
        NonMongoidDocument.includes_many :non_mongoid_embeds
      rescue => e
        e.class.should == Mongoid::DocumentInclusion::NotMongoidDocument
        e.message.should =~ /Document must be a Mongoid Document/
      end
    end
    
    it "issues an error if child is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.const_set "NonMongoidEmbed", Class.new
      NonMongoidDocument.send(:include, Mongoid::Document)
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      begin
        NonMongoidDocument.includes_many :non_mongoid_embeds
      rescue => e
        e.class.should == Mongoid::DocumentInclusion::NotMongoidDocument
        e.message.should =~ /Descendent document must be a Mongoid Document/
      end
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
    
    it "strips namespace from param_key" do
      Invoice::Item.model_name.param_key.should == "item"
    end
    
    it "strips namespace from #route_key" do
      Invoice::Item.model_name.route_key.should == "items"
    end
    
    it "forbids inclusion in another parent" do
      begin
        Invoice::Item.included_in :invoice
      rescue => e
        e.class.should == Mongoid::DocumentInclusion::DocumentAlreadyIncluded
      end
    end
  
    
    it "issues an error if parent is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.const_set "NonMongoidParent", Class.new
      NonMongoidDocument.send(:include, Mongoid::Document)
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      begin
        NonMongoidDocument.included_in :invoice
      rescue => e
        e.class.should == Mongoid::DocumentInclusion::NotMongoidDocument
        e.message.should =~ /Parent document must be a Mongoid Document/
      end
    end    
    
    it "issues an error if parent is not mongoid document" do
      Object.const_set "NonMongoidDocument", Class.new
      NonMongoidDocument.const_set "NonMongoidParent", Class.new
      NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
      begin
        NonMongoidDocument.included_in :invoice
      rescue => e
        e.class.should == Mongoid::DocumentInclusion::NotMongoidDocument
        e.message.should =~ /Document must be a Mongoid Document/
      end
    end
    
  end
  
end

