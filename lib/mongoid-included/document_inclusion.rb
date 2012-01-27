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
        @skip_path_pluralization = args && args.delete(:skip_path_pluralization)
        if args && args[:class_name]
          _class_name = args[:class_name]
        else
          _class_name = _model
        end
        
        raise NotMongoidDocument,       "Parent must be Mongoid::Document" unless _mongoid_document? self.parent
        raise DocumentAlreadyIncluded,  "Document already included" if (!included_by.blank? && included_by!=[_model_klass(_class_name)]) 
        embedded_in _model, args
        
        self.included_by ||= []
        self.included_by << _model_klass(_class_name) unless included_by.include? _model_klass(_class_name)
        self.extend ActiveModel::Naming
        _overwrite_model_name
      end
      
      def includes_many(_model, args = {})
        if args && args[:class_name]
          _class_name = args[:class_name]
          self.including_many ||= []
          self.including_many << _model_klass(_class_name) unless including_many.include? _model_klass(_class_name)
        else
          _verify_dependencies(_model)
          _class_name = _included_klass_name(_model)
          self.including_many ||= []
          self.including_many << _included_klass(_model) unless including_many.include? _included_klass(_model)
        end
        embeds_many _model, args.merge(:class_name => _class_name )
      end
      
      def includes_one(_model, args = {})
        if args && args[:class_name]
          _class_name = args[:class_name]
          self.including_one ||= []
          self.including_one << _model_klass(_class_name) unless including_one.include? _model_klass(_class_name)
        else
          _verify_dependencies(_model)
          _class_name = _included_klass_name(_model)
          self.including_one ||= []
          self.including_one << _included_klass(_model) unless including_one.include? _included_klass(_model)
        end
        embeds_one _model, args.merge(:class_name => _class_name)
      end
      
      private
      
      def _overwrite_model_name
        if self.parent != Object
          self.class_eval <<-EOF
            def self.model_name
              @_model_name ||=begin
                ActiveModel::Name.new(self, self.parent)
              end
            end
          EOF
          unless @skip_path_pluralization
            self.class_eval <<-EOF
              def self._to_partial_path
                @_to_partial_path ||= begin
                  plural_namespace = ActiveSupport::Inflector.tableize(self.parent).freeze
                  plural_element = ActiveSupport::Inflector.pluralize(model_name.element)
                  path = [plural_namespace, plural_element, model_name.element].join("/").freeze
                end
              end
            EOF
          end
        end
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
