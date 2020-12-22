require "parslet"
require "set"

module AdventOfCode
  class Day21 < Day
    input_file do |lines|
      ingredients = lines.map { |line| Recipe.parse(line) }
      Recipes.new(ingredients)
    end
    alias_method :recipes, :input

    part1 answer: 1679 do
      safe = recipes.safe_ingredients
      recipes.all.sum do |recipe|
        recipe.ingredients.count { |ing| safe.member?(ing) }
      end
    end

    class Recipes
      attr_reader :recipes

      alias_method :all, :recipes

      def initialize(recipes)
        @recipes = recipes
      end

      def safe_ingredients
        all_ingredients - unsafe_ingredients
      end

      def unsafe_ingredients
        allerg_to_ing = {}

        recipes.each do |recipe|
          recipe.allergens.each do |ing|
            allerg_to_ing[ing] ||= Set.new(recipe.ingredients)
            allerg_to_ing[ing] = allerg_to_ing[ing].intersection(recipe.ingredients)
          end
        end

        allerg_to_ing.values.reduce(:union)
      end

      def all_ingredients
        recipes.map(&:ingredients).reduce(:union)
      end
    end

    class Recipe < Struct.new(:ingredients, :allergens, keyword_init: true)
      def self.parse(str)
        result = IngredientsTransform.new.apply(IngredientsParser.new.parse(str))
        new(
          ingredients: Set.new(result[:ingredients]),
          allergens: Set.new(result[:allergens])
        )
      end
    end

    class IngredientsParser < Parslet::Parser
      rule(:allergen) { match('\w').repeat(1) }
      rule(:allergens) {
        str("(contains ") >>
        (allergen.as(:allergen) >> str(", ").maybe).repeat(1) >>
        str(")")
      }
      rule(:ingredient) { match('\w').repeat(1) }
      rule(:ingredients) { (ingredient.as(:ingredient) >> match('\s').maybe).repeat(1) }
      rule(:list) { ingredients.as(:ingredients) >> allergens.as(:allergens) }

      root(:list)
    end

    class IngredientsTransform < Parslet::Transform
      rule(allergen: simple(:s))  { s.to_s }
      rule(ingredient: simple(:s))  { s.to_s }
    end
  end
end
