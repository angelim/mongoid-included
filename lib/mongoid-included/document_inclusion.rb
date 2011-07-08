require 'mongoid-included/embedded_name'
require 'mongoid-included/inclusion_errors'
module Mongoid
  module DocumentInclusion
    extend ActiveSupport::Concern
      
    included do
      cattr_accessor :included_by
      cattr_accessor :including_many
      cattr_accessor :including_one
    end
    
    module ClassMethods
      def included_in(_model, args = {})
        raise NotMongoidDocument,       "Parent must be Mongoid::Document" unless _mongoid_document? self.parent
        raise DocumentAlreadyIncluded,  "Document already included" if !included_by.blank?
        embedded_in _model, args
        
        (self.included_by ||=[]) << _model_klass(_model)
        self.extend ActiveModel::Naming
        _overwrite_model_name
      end
      
      def includes_many(_model, args = {})
        _verify_dependencies(_model)
        embeds_many _model, args.merge(:class_name => _included_klass_name(_model))
        (self.including_many ||= []) << _included_klass(_model)
      end
      
      def includes_one(_model, args = {})
        _verify_dependencies(_model)
        embeds_one _model, args.merge(:class_name => _included_klass_name(_model))
        (self.including_one ||= []) << _included_klass(_model)
      end
      
      private
      
      def _overwrite_model_name
        self.class_eval <<-EOF
          @_model_name ||=begin
            if self.parent != Object
              Mongoid::EmbeddedName.new(self, self.parent)
            else
              super
            end
          end
        EOF
      end
      
      def _model_klass_name(_model)
        _model.to_s.classify
      end
      
      def _model_klass(_model)
        _model.to_s.classify.constantize
      end
      
      def _included_klass_name(_model)
        "#{self}::#{_model_klass_name(_model)}"
      end
      
      def _included_klass(_model)
        "#{self}::#{_model_klass_name(_model)}".constantize
      end
        
      def _mongoid_document?(_model)
        _model.included_modules.include?(Mongoid::Document)
      end
      
      def _verify_dependencies(_model)
        raise NotMongoidDocument, "Child must be Mongoid::Document" unless _mongoid_document? _model_klass(_included_klass_name(_model))
      end
    end
  end
end
