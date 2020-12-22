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

    part2 answer: "lmxt,rggkbpj,mxf,gpxmf,nmtzlj,dlkxsxg,fvqg,dxzq" do
      ing_to_alg = recipes.ingredients_to_allergen
      ing_to_alg.keys.sort_by { |ing| ing_to_alg[ing] }.join(",")
    end

    class Recipes
      attr_reader :recipes

      alias_method :all, :recipes

      def initialize(recipes)
        @recipes = recipes
      end

      def ingredients_to_allergen
        alg_to_ing = {}

        recipes.each do |recipe|
          recipe.allergens.each do |allergen|
            alg_to_ing[allergen] ||= Set.new(recipe.ingredients)
            alg_to_ing[allergen] = alg_to_ing[allergen].intersection(
              recipe.ingredients - safe_ingredients
            )
          end
        end

        res = {}

        until alg_to_ing.values.empty?
          alg, ings = alg_to_ing.find { |_, ings| ings.size == 1 }
          ing = ings.first

          alg_to_ing.delete(alg)
          alg_to_ing.each_value { |ings| ings.delete(ing) }

          res[ing] = alg
        end

        res
      end

      def safe_ingredients
        all_ingredients - unsafe_ingredients
      end

      def unsafe_ingredients
        alg_to_ing = {}

        recipes.each do |recipe|
          recipe.allergens.each do |alg|
            alg_to_ing[alg] ||= Set.new(recipe.ingredients)
            alg_to_ing[alg] = alg_to_ing[alg].intersection(recipe.ingredients)
          end
        end

        alg_to_ing.values.reduce(:union)
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
