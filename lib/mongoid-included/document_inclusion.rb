require 'mongoid-included/inclusion_errors'
module Mongoid
  module DocumentInclusion
    # Adds convenience methods to embed Mongoid documents into others using namespaces.
    # It also provides methods to define their inverse relation, on root documents.
    extend ActiveSupport::Concern
      
    included do
      # @return [ Array ] list of classes in which a class is included in an +Embedded Relation+.
      cattr_accessor :included_by
      # @return [ Array ] list of classes a given class includes in a +Many Relation+.
      cattr_accessor :including_many
      # @return [ Array ] list of classes a given class includes in a +One Relation+.
      cattr_accessor :including_one
      
      self.included_by, self.including_many, self.including_one = [], [], []
    end
    
    module ClassMethods
      # Facade for Mongoid::Relations::Macros.embeded_in
      # @param [ Symbol ] relation_name name for the parent association
      # @param [ Hash ] args (see Mongoid::Relations::Macros.embeded_in)
      # @option args [ true, false ] :skip_path_pluralization If Partial Paths should be
      #   kept as default, using the namespace in singular form
      # 
      # @example Skipping pluralization
      #   class Entry::Image
      #     included_in :entry, :skip_path_pluralization => true
      #     image.to_partial_path #=> "entry/images/image"
      # 
      # @example With pluralization. This seems a more natural fit for partials placement.
      #   class Entry::Image
      #     included_in :entry
      #     image.to_partial_path #=> "entries/images/image"
      def included_in(relation_name, args = {})
        @skip_path_pluralization = args.delete(:skip_path_pluralization)
        
        relation_klass = if args[:class_name]
          infer_klass(args[:class_name])
        else
          infer_klass(relation_name)
        end 
        
        raise NotMongoidDocument,       "Parent must be Mongoid::Document" unless has_mongoid? self.parent
        raise DocumentAlreadyIncluded,  "Document already included" if (included_by | [ relation_klass ]).size > 1
        
        embedded_in relation_name, args
        self.included_by |= [ relation_klass ]
        
        self.extend ActiveModel::Naming
        _overwrite_model_name
      end
      
      # Facade for Mongoid::Relations::Macros.embeds_many
      # @param [ Symbol ] relation_name Name for the child association
      # @param [ Hash ] args (see Mongoid::Relations::Macros.embeds_many)
      def includes_many(relation_name, args = {})
        relation_klass = if args[:class_name]
          infer_klass(args[:class_name])
        else
          klass_to_include(relation_name)
        end
        
        verify_inclusion_dependencies(relation_klass)
        self.including_many |= [ relation_klass ]

        embeds_many relation_name, args.merge(:class_name => relation_klass.name )
      end
      
      
      # Facade for Mongoid::Relations::Macros.embeds_one
      # @param [ Symbol ] _model Name for the association
      # @param [ Hash ] args (see Mongoid::Relations::Macros.embeds_one)
      def includes_one(relation_name, args = {})
        relation_klass = if args[:class_name]
          infer_klass(args[:class_name])
        else
          klass_to_include(relation_name)
        end
        
        verify_inclusion_dependencies(relation_klass)
        self.including_one |= [ relation_klass ]

        embeds_one relation_name, args.merge(:class_name => relation_klass.name )
      end
      
      private
      
      # Overrides +ActiveModel.model_name+ and +Model._to_partial_path+ 
      #   for ActiveModel compliant classes.
      # @note This method requires ActiveModel ~> 3.2. This release deprecates
      #   ActiveModel::Naming#partial_path in favor or model.to_partial_path.
      # @since 1.0.0
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
      
      # Returns the class for a given name
      # @param [ Symbol ] _model the relation name
      # @return [ Object <Mongoid::Document> ] the model class
      # @example A relation named :entry
      #   infer_klass("Entry::Image") #=> Entry::Image
      def infer_klass(klass_name)
        klass_name.to_s.classify.constantize
      end
      
      # Returns the class for a given relation
      # @param [ Symbol ] relation_name the relation name
      # @return [ Class ] the model class
      # @example A relation named :comments for an Entry class
      #   klass_to_include(:comments) #=> Entry::Comment
      def klass_to_include(relation_name)
        "#{self}/#{relation_name}".classify.constantize
      end
      
      # If relation name targets a Mongoid Document
      # @param [ Symbol ] _model the relation name
      # @return [ true, false ] if relation is a Mongoid::Document
      def has_mongoid?(embeding_target)
        embeding_target < Mongoid::Document
      end
      
      # Verifies if an association can be included
      # @param [ Symbol ] _model the relation name
      # @raise [ NotMongoidDocument ] if relation is not a Mongoid::Document
      def verify_inclusion_dependencies(relation_klass)
        raise NotMongoidDocument, "Child must be Mongoid::Document" unless has_mongoid? relation_klass
      end
    end
  end
end
