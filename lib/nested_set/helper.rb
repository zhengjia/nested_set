# encoding: utf-8
module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      # This module provides some helpers for the model classes using acts_as_nested_set.
      # It is included by default in all views.
      #
      module Helper
        # Returns options for select.
        # You can exclude some items from the tree.
        # You can pass a block receiving an item and returning the string displayed in the select.
        #
        # == Params
        #  * +class_or_item+ - Class name or top level times
        #  * +mover+ - The item that is being move, used to exlude impossible moves
        #  * +&block+ - a block that will be used to display: { |item| ... item.name }
        #
        # == Usage
        #
        #   <%= f.select :parent_id, nested_set_options(Category, @category) {|i, level|
        #       "#{'–' * level} #{i.name}"
        #     }) %>
        #
        def nested_set_options(class_or_item, mover = nil)
          class_or_item = class_or_item.roots if class_or_item.is_a?(Class)
          items = Array(class_or_item)
          result = []
          items.each do |root|
            levels = []
            result += root.self_and_descendants.map do |i|
              if level = levels.index(i.parent_id)
                levels.slice!((level + 1)..-1)
              else
                levels << i.parent_id
                level = levels.size - 1
              end
              if mover.nil? || mover.new_record? || mover.move_possible?(i)
                [yield(i, level), i.id]
              end
            end.compact
          end
          result
        end

        # Returns options for select.
        # You can sort node's child by any method
        # You can exclude some items from the tree.
        # You can pass a block receiving an item and returning the string displayed in the select.
        #
        # == Params
        #  * +class_or_item+ - Class name or top level times
        #  * +sort_proc+ sorting proc for node's child, ex. lambda{|x| x.name}
        #  * +mover+ - The item that is being move, used to exlude impossible moves
        #  * +level+ - start level, :default => 0
        #  * +&block+ - a block that will be used to display: { |itemi, level| "#{'–' * level} #{i.name}" }
        # == Usage
        #
        #   <%= f.select :parent_id, sorted_nested_set_options(Category, lambda(&:name)) {|i, level|
        #       "#{'–' * level} #{i.name}"
        #     }) %>
        #
        #   OR
        #
        #   sort_method = lambda{|x,y| x.name.downcase <=> y.name.downcase}
        #
        #   <%= f.select :parent_id, nested_set_options(Category, sort_method) {|i, level|
        #       "#{'–' * level} #{i.name}"
        #     }) %>
        #
        def sorted_nested_set_options(class_or_item, sort_proc, mover = nil, level = 0)
          class_or_item = class_or_item.roots if class_or_item.is_a?(Class)
          items = Array(class_or_item)
          result = []
          items.sort_by(&sort_proc).each do |root|
            set = root.self_and_descendants
            result += build_node(set[0], set, sort_proc, mover, level){|x, lvl| yield(x, lvl)}
          end
          result
        end

        def build_node(node, set, sort_proc, mover = nil, level = nil)
          result ||= []
          if mover.nil? || mover.new_record? || mover.move_possible?(i)
            result << [yield(node, level), node.id]
            unless node.leaf?
              set.select{|i| i.parent_id == node.id}.sort_by(&sort_proc).map{ |k|
                result.push(*build_node(k, set, sort_proc, mover, level.to_i + 1){|x, lvl| yield(x, lvl)})
              }
            end
          end
          result
        end
      end
    end
  end
end
