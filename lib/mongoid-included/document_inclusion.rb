module Mongoid
  module DocumentInclusion
    extend ActiveSupport::Concern
    
    class NotMongoidDocument < StandardError; end;
    class DocumentAlreadyIncluded < StandardError; end;
      
    included do
      extend ActiveModel::Naming
      cattr_accessor :inclusion_model
    end
    
    module ClassMethods
      def included_in(_model, args = {})
        raise NotMongoidDocument,       "Child document must include Mongoid::Document" unless mongoid_document? self
        raise NotMongoidDocument,       "Parent document must include Mongoid::Document" unless mongoid_document? self.parent
        raise DocumentAlreadyIncluded,  "Child document already included" if inclusion_model
        embedded_in _model, args
        self.inclusion_model = true
      end
      
      def includes_many(_model, args = {})
        verify_dependencies(_model)
        embeds_many _model, args.merge(:class_name => included_klass(_model))
        self.inclusion_model = true
      end
      
      def includes_one(_model, args = {})
        verify_dependencies(_model)
        embeds_one _model, args.merge(:class_name => included_klass(_model))
        self.inclusion_model = true
      end
      
      def model_name
        @_model_name ||=begin
          if self.parent != Object
            Mongoid::EmbeddedName.new(self, self.parent)
          else
            super
          end
        end
      end
      
      private
      
      def model_klass_name(_model)
        _model.to_s.classify
      end
      
      def model_klass(_model)
        _model.to_s.classify.constantize
      end
      
      def included_klass(_model)
        "#{self}::#{model_klass_name(_model)}"
      end
        
      def mongoid_document?(_model)
        _model.ancestors.include?(Mongoid::Document)
      end
      
      def verify_dependencies(_model)
        raise NotMongoidDocument,       "Parent document must include Mongoid::Document" unless mongoid_document? self
        raise NotMongoidDocument,       "Child document must include Mongoid::Document" unless mongoid_document? model_klass(included_klass(_model))
      end
      
    end
  end
end
