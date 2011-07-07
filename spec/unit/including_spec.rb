require 'spec_helper'

describe "Parent Model" do
  
  let(:parent) { Invoice }
  
  describe "#includes_many" do
    context "when including one model" do
      it "#includding_many returns array with one model" do
        parent.including_many.should include(:items)
      end
      it "embeds child with association name" do
        parent.relations.keys.should include "items"
        parent.relations["items"].macro.should == :embeds_many
      end
      it "embeds child with association class" do
        parent.relations["items"].class_name.should == "Invoice::Item"
      end
    end
    context "when including two models" do
      it "#includding_many returns array with two models" do
        parent.includes_many :not_includeds
        parent.including_many.should include(:items, :not_includeds)
      end
    end
    context "when not including with #includes_many" do
      it "#includding_many returns an empty array" do
        Invoice::Item.including_many.should be_blank
      end
    end
  end
  
  describe "#includes_one" do
    context "when including one model" do
      it "#including_one returns array with one model" do
        parent.including_one.should include(:user)
      end
      it "delegates options to mongoid relation macro" do
        parent.relations["user"].inverse_of.should == :invoice
      end
      it "embeds one child with given association name" do
        parent.relations.keys.should include "user"
        parent.relations["user"].macro.should == :embeds_one
      end
    end
    context "when including two models" do
      it "#includding_one returns array with two models" do
        parent.includes_one :not_includeds
        parent.including_one.should include(:user, :not_includeds)
      end
    end
    context "when not including with #includes_one" do
      it "#includding_one returns an empty array" do
        Invoice::Item.including_one.should be_blank
      end
    end
  end

  it "issues an error if child is not mongoid document" do
    Object.const_set "NonMongoidDocument", Class.new
    NonMongoidDocument.const_set "NonMongoidEmbed", Class.new
    NonMongoidDocument.send(:include, Mongoid::Document)
    NonMongoidDocument.send(:include, Mongoid::DocumentInclusion)
    expect {NonMongoidDocument.includes_many :non_mongoid_embeds }.
    to raise_error(Mongoid::DocumentInclusion::NotMongoidDocument, /Child must be Mongoid::Document/)
  end

end
