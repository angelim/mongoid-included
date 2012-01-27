Mongoid::Included
====================

Helper module to embed documents using the parent's namespace while preserving url helpers consistency. 
This is useful to organize your project if you heavily rely on embedded documents. 
This gem concerns the issue 1429 of rails repository: https://github.com/rails/rails/issues/1429
Works with [Mongoid 2.4](https://github.com/mongoid/mongoid) and ActiveModel 3.2.0. 

Installation
------------

Add the gem to your Bundler `Gemfile`:

    gem 'mongoid-included'

Or install with RubyGems:

    $ gem install mongoid-included


Usage
-----

In your embedded model:

	# Include the helper module
	include Mongoid::DocumentInclusion

	# Define parent document in embedded class
	included_in :invoice

In your parent model:

	# Define embedded relation in parent document
	includes_many :items
	includes_one :user
    

Example
-------

	class Invoice
		include Mongoid::Document
		
		includes_many :items
	end
	
	# This will generate a Mongoid Relation with the following signature:
		embeds_many :items, :class_name => Invoice::Item

	class Invoice::Item
		include Mongoid::Document
	
		included_in :invoice
	end
	# This will generate the following code:
		extend ActiveModel::Naming
		# Overriding .model_name so rails recognizes the class as __Item__ and generate more convenient urls.
		def self.model_name
			if self.parent != Object
				ActiveModel::Name.new(self, self.parent)
			else
				super
			end
		end
		
		embedded_in :invoice

	# Define routes with the embedded document as a nested resource
	resources :invoices do
		resources :items
	end
	
	# if you decide that the controller should also use namespaces, place the __items_controller__ inside an __invoices__ folder and use:
	resources :invoices do
		resources :items, :module => :invoices
	end
	
	
	
Rake tasks
----------

Todo
----------

Known issues
------------


Credits
-------

Copyright (c) 2011 Alexandre Angelim, released under the MIT license.