# encoding: utf-8
module CollectiveIdea
  module Acts
    module NestedSet
      class Engine < ::Rails::Engine
        config.after_initialize do
          ActiveRecord::Base.class_eval do
            include CollectiveIdea::Acts::NestedSet::Base
          end
          
          if Object.const_defined?("ActionView")
            ActionView::Base.class_eval do
              include CollectiveIdea::Acts::NestedSet::Helper
            end
          end
        end
      end
    end
  end
end
