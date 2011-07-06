module Mongoid
  class EmbeddedName < ActiveModel::Name
    attr_reader :singular, :plural, :element, :collection, :partial_path, :route_key, :param_key, :i18n_key
    alias_method :cache_key, :collection

    def initialize(klass, namespace, pluralize_namespace = true)
      name ||= klass.name
      # super(name)
      @unnamespaced = name.sub(/^#{namespace.name}::/, '') if namespace

      @klass = klass
      @singular = _singularize(name).freeze
      @singular_namespace = _singularize(namespace.name).freeze
      @plural = ActiveSupport::Inflector.pluralize(@singular).freeze
      @plural_namespace = ActiveSupport::Inflector.pluralize(@singular_namespace).freeze
      @element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(name)).freeze
      @human = ActiveSupport::Inflector.humanize(@element).freeze
      @collection = ActiveSupport::Inflector.tableize(name).freeze
      @partial_path = "#{@collection.sub(@singular_namespace, @plural_namespace)}/#{@element}".freeze
      @param_key =  _singularize(@unnamespaced).freeze
      @route_key = ActiveSupport::Inflector.pluralize(@param_key).freeze
      @i18n_key = name.underscore.to_sym
    end
    
    def _singularize(string, replacement='_')
      ActiveSupport::Inflector.underscore(string).tr('/', replacement)
    end
  end
end