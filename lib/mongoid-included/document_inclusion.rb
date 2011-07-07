require 'mongoid-included/embedded_name'
require 'mongoid-included/inclusion_errors'
module Mongoid
  module DocumentInclusion
    extend ActiveSupport::Concern
      
    included do
      cattr_accessor :_using_inclusion
    end
    
    module ClassMethods
      def included_in(_model, args = {})
        raise NotMongoidDocument,       "Child document must include Mongoid::Document" unless mongoid_document? self
        raise NotMongoidDocument,       "Parent document must include Mongoid::Document" unless mongoid_document? self.parent
        raise DocumentAlreadyIncluded,  "Child document already included" if _using_inclusion
        embedded_in _model, args
        
        self._using_inclusion = true
        self.extend ActiveModel::Naming
        _overwrite_model_name
      end
      
      def includes_many(_model, args = {})
        _verify_dependencies(_model)
        embeds_many _model, args.merge(:class_name => _included_klass(_model))
      end
      
      def includes_one(_model, args = {})
        _verify_dependencies(_model)
        embeds_one _model, args.merge(:class_name => _included_klass(_model))
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
      
      def _included_klass(_model)
        "#{self}::#{_model_klass_name(_model)}"
      end
        
      def mongoid_document?(_model)
        _model.ancestors.include?(Mongoid::Document)
      end
      
      def _verify_dependencies(_model)
        raise NotMongoidDocument,       "Parent document must include Mongoid::Document" unless mongoid_document? self
        raise NotMongoidDocument,       "Child document must include Mongoid::Document" unless mongoid_document? _model_klass(_included_klass(_model))
      end
    end
  end
end
Mongoid::Document.send(:include, ::Mongoid::DocumentInclusion)
