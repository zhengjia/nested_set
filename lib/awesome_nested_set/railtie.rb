# encoding: utf-8
require 'awesome_nested_set'

module CollectiveIdea
  module Acts
    module NestedSet
      if defined? Rails::Railtie
        require 'rails'
        class Railtie < Rails::Railtie
          initializer "awesome_nested_set.initialization" do
            CollectiveIdea::Acts::NestedSet::Railtie.insert
          end
        end
      end

      class Railtie
        def self.insert
          ActiveRecord::Base.send(:include, CollectiveIdea::Acts::NestedSet::Base)
          
          if Object.const_defined?("ActionView")
            ActionView::Base.send(:include, CollectiveIdea::Acts::NestedSet::Helper)
          end
        end
      end
    end
  end
end
