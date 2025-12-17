# -------------------- 1) Конвертація одиниць --------------------
class UnitConverter
  GROUP = { g: :g, kg: :g, ml: :ml, l: :ml, pcs: :pcs }
  TO_BASE = { g: 1.0, kg: 1000.0, ml: 1.0, l: 1000.0, pcs: 1.0 }

  def self.convert(qty, from, to)
    from = from.to_sym
    to   = to.to_sym
    raise "Unknown unit #{from}" unless GROUP.key?(from)
    raise "Unknown unit #{to}"   unless GROUP.key?(to)
    raise "Incompatible units #{from} -> #{to}" unless GROUP[from] == GROUP[to]

    qty.to_f * TO_BASE[from] # завжди повертаємо у базових одиницях
  end

  def self.base_of(unit)
    GROUP[unit.to_sym] || (raise "Unknown unit #{unit}")
  end
end

# -------------------- 2) Модель інгредієнта --------------------
class Ingredient
  attr_reader :name, :unit, :cal_per_base

  def initialize(name, unit, cal_per_base)
    @name = name.to_s
    @unit = unit.to_sym
    @cal_per_base = cal_per_base.to_f
  end

  def base_unit
    UnitConverter.base_of(@unit)
  end
end

# -------------------- 3) Рецепт --------------------
class Recipe
  attr_reader :name, :items

  def initialize(name)
    @name  = name.to_s
    @items = []
  end

  def add(ingredient, qty, unit)
    @items << { ingredient: ingredient, qty: qty.to_f, unit: unit.to_sym }
  end

  def need
    need_map = {}
    @items.each do |it|
      ing  = it[:ingredient]
      base = ing.base_unit
      q    = UnitConverter.convert(it[:qty], it[:unit], base)
      rec  = (need_map[ing.name] ||= { qty: 0.0, unit: base, ingredient: ing })
      rec[:qty] += q
    end
    need_map
  end
end

# -------------------- 4) Комора --------------------
class Pantry
  def initialize
    @stock = {}
  end

  def add(name, qty, unit)
    base = UnitConverter.base_of(unit)
    q    = UnitConverter.convert(qty, unit, base)
    row  = (@stock[name.to_s] ||= { qty: 0.0, unit: base })
    row[:qty] += q
  end

  def available_for(name)
    row = @stock[name.to_s]
    row ? { qty: row[:qty], unit: row[:unit] } : { qty: 0.0, unit: nil }
  end
end

# -------------------- 5) Планувальник --------------------
class Planner
  def self.plan(recipes, pantry, prices)
    total_need = {}

    recipes.each do |r|
      r.need.each do |name, info|
        row = (total_need[name] ||= { qty: 0.0, unit: info[:unit], ingredient: info[:ingredient] })
        row[:qty] += info[:qty]
      end
    end

    summary = {}
    kcal_sum = 0.0
    cost_sum = 0.0

    total_need.each do |name, info|
      need   = info[:qty]
      unit   = info[:unit]
      ing    = info[:ingredient]
      have   = pantry.available_for(name)[:qty]
      deficit = [need - have, 0.0].max

      price  = (prices[name] || 0.0).to_f
      cost   = need * price
      cals   = need * ing.cal_per_base

      kcal_sum += cals
      cost_sum += cost

      summary[name] = {
        need: need, have: have, deficit: deficit, unit: unit,
        price_per_base: price, cost_for_need: cost, calories_for_need: cals
      }
    end

    { summary: summary, total_calories: kcal_sum, total_cost: cost_sum }
  end
end

# -------------------- 6) Демо-перевірка --------------------
if __FILE__ == $0
  flour  = Ingredient.new('борошно', :g, 3.64)
  milk   = Ingredient.new('молоко',  :ml, 0.06)
  egg    = Ingredient.new('яйце',    :pcs, 72.0)
  pasta  = Ingredient.new('паста',   :g, 3.5)
  sauce  = Ingredient.new('соус',    :ml, 0.2)
  cheese = Ingredient.new('сир',     :g, 4.0)

  pantry = Pantry.new
  pantry.add('борошно', 1,   :kg)
  pantry.add('молоко',  0.5, :l)
  pantry.add('яйце',    6,   :pcs)
  pantry.add('паста',   300, :g)
  pantry.add('сир',     150, :g)

  prices = {
    'борошно' => 0.02,
    'молоко'  => 0.015,
    'яйце'    => 6.0,
    'паста'   => 0.03,
    'соус'    => 0.025,
    'сир'     => 0.08
  }

  omlet = Recipe.new('Омлет')
  omlet.add(egg,   3,   :pcs)
  omlet.add(milk,  100, :ml)
  omlet.add(flour, 20,  :g)

  pasta_r = Recipe.new('Паста')
  pasta_r.add(pasta,  200, :g)
  pasta_r.add(sauce,  150, :ml)
  pasta_r.add(cheese, 50,  :g)

  res = Planner.plan([omlet, pasta_r], pantry, prices)

  puts "--- План: Омлет + Паста ---"
  res[:summary].each do |name, s|
    printf "%-8s потрібно: %8.2f %-3s | є: %8.2f %-3s | дефіцит: %8.2f %-3s\n",
           name, s[:need], s[:unit], s[:have], s[:unit], s[:deficit], s[:unit]
  end
  puts
  printf "Total calories: %.2f kcal\n", res[:total_calories]
  printf "Total cost:     %.2f\n",       res[:total_cost]
end