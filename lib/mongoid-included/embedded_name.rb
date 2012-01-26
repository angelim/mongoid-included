module Mongoid
  class EmbeddedName < String
    attr_reader :singular, :plural, :element, :collection, :partial_path, :route_key, :param_key, :i18n_key
    alias_method :cache_key, :collection

    def initialize(klass, namespace, name = nil, pluralize_namespace = true)
      name ||= klass.name
      super(name)
      @unnamespaced = name.sub(/^#{namespace.name}::/, '')
      
      @klass = klass
      @singular = _singularize(name).freeze
      @singular_namespace = _singularize(namespace.name).freeze
      @plural = ActiveSupport::Inflector.pluralize(@singular).freeze
      @plural_namespace = ActiveSupport::Inflector.pluralize(@singular_namespace).freeze
      @element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(name)).freeze
      @human = ActiveSupport::Inflector.humanize(@element).freeze
      @collection = ActiveSupport::Inflector.tableize(name).freeze
      @partial_path = (pluralize_namespace  ? "#{@collection.sub(@singular_namespace, @plural_namespace)}/#{@element}" 
                                            : "#{@collection}/#{@element}").freeze
      @param_key =  _singularize(@unnamespaced).freeze
      @route_key = ActiveSupport::Inflector.pluralize(@param_key).freeze
      @i18n_key = name.underscore.to_sym
    end
    
    def human(options={})
      return @human unless @klass.respond_to?(:lookup_ancestors) &&
                           @klass.respond_to?(:i18n_scope)

      defaults = @klass.lookup_ancestors.map do |klass|
        klass.model_name.i18n_key
      end

      defaults << options[:default] if options[:default]
      defaults << @human

      options = {:scope => [@klass.i18n_scope, :models], :count => 1, :default => defaults}.merge(options.except(:default))
      I18n.translate(defaults.shift, options)
    end
    
    def _singularize(string, replacement='_')
      ActiveSupport::Inflector.underscore(string).tr('/', replacement)
    end
  end
end