Mongoid::Included
====================

Helper module to embed documents using the parent's namespace while preserving url helpers consistence. 
Works with [Mongoid 2.0](https://github.com/mongoid/mongoid) and ActiveModel 3.1.0.beta1. 

Installation
------------

Add the gem to your Bundler `Gemfile`:

    gem 'mongoid-included'

Or install with RubyGems:

    $ gem install mongoid-included


Usage
-----

In your root(master) model:

	# Include the helper module
	include Mongoid::DocumentInclusion

	# Define parent document in embedded class
	included_in :invoice
	
	# Define embedded relation in parent document
	includes_many :items
	includes_one :user
    

Example
-------

	class Invoice
		include Mongoid::Document
		include Mongoid::DocumentInclusion
		
		includes_many :items
	end
	
	# This will generate a Mongoid Relation with the following signature:
		embeds_many :items, :class_name => Invoice::Item

	class Invoice::Item
		include Mongoid::Document
		include Mongoid::DocumentInclusion
	
		included_in :invoice
	end
	# This will generate the following code:
		extend ActiveModel::Naming
		# Overriding .model_name so rails recognize the class as __Item__ and generate more convenient urls.
		def model_name
			if self.parent != Object
				ActiveModel::Name.new(self, self.parent)
			else
				super
			end
		end
		
		embedded_in :invoice

Rake tasks
----------

should include tasks to re-sync


Todo
----------
- Delegate other mongoid options when generating relation macros. (eg. index)

Known issues
------------


Credits
-------

Copyright (c) 2011 Alexandre Angelim, released under the MIT license.