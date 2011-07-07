require 'mongoid'
require 'mongoid-included/document_inclusion'
Mongoid::Document.send(:include, ::Mongoid::DocumentInclusion)