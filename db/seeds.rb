# db/seeds.rb
# Idempotent seed for the family catering business.
# Run with: bin/rails db:seed
# Safe to re-run — it only creates records that don't exist.

puts "Seeding catering business..."

# ─── 1. User for Janet ────────────────────────────────────────────────────
mama_email = "meellyotieno@gmail.com"
User.find_or_create_by!(email: mama_email) do |u|
  u.full_name             = "Janet Otieno"
  u.password              = "changeme123"              # change on first login
  u.password_confirmation = "changeme123"
end
puts "✓ User: #{mama_email} / changeme123 (Janet Otieno)"

# ─── 2. Company settings ──────────────────────────────────────────────────
setting = Setting.instance
setting.update!(
  company_name:    "Netty's Kitchen",            # <-- fill in
  company_address: "95023 - 80100, Mombasa",
  company_phone:   "0721341509",        # <-- fill in
  company_email:   "meellyotieno@gmail.com",
  company_website: "",
  currency:        "KES",
  tax_rate:        0.0,
  payment_terms:   "Net 7",
  invoice_prefix:  "INV-"
)
puts "✓ Company settings updated for #{setting.company_name}"

# ─── 3. Menu items (products) ─────────────────────────────────────────────
# FILL IN mum's real menu items and prices. These are placeholders based on
# typical Kenyan catering — swap with what she actually charges.
menu = [
  { name: "Chapati (dozen)",              price: 300,  category: "Bread" },
  { name: "Mandazi (dozen)",              price: 250,  category: "Bread" },
  { name: "Chicken Pilau (per plate)",    price: 350,  category: "Main" },
  { name: "Beef Pilau (per plate)",       price: 300,  category: "Main" },
  { name: "Vegetable Pilau (per plate)",  price: 250,  category: "Main" },
  { name: "Whole Roast Chicken",          price: 1200, category: "Main" },
  { name: "Chapati + Beef Stew (per plate)", price: 250, category: "Main" },
  { name: "Wedding Cake (small tier)",    price: 3500, category: "Baking" },
  { name: "Wedding Cake (medium tier)",   price: 6000, category: "Baking" },
  { name: "Birthday Cake (custom)",       price: 4500, category: "Baking" },
  { name: "Samosas (dozen)",              price: 400,  category: "Snacks" },
  { name: "Bhajia (per plate)",           price: 200,  category: "Snacks" },
  { name: "Chai (per person, event)",     price: 50,   category: "Beverages" },
  { name: "Passion Juice (per litre)",    price: 250,  category: "Beverages" }
]

menu.each do |item|
  Product.find_or_create_by!(name: item[:name]) do |p|
    p.category    = item[:category]
    p.description = "#{item[:name]} at KES #{item[:price]}"
    p.active      = true
  end
end
puts "✓ #{menu.length} menu items seeded"

# ─── 4. One sample invoice (so she can see the output shape) ──────────────
if Invoice.count.zero?
  invoice = Invoice.new(
    invoice_date:   Date.current,
    due_date:       Date.current + 7.days,
    client_name:    "Sample Wedding Order — Mr. & Mrs. Otieno",
    client_address: "Nyali, Mombasa",
    client_email:   "sample@example.com",
    tax_rate:       0.0,
    notes:          "Sample invoice — feel free to delete once you're comfortable with the format."
  )

  # Look up the placeholder prices from the menu list above
  price_of = ->(name) { menu.find { |m| m[:name] == name }[:price] }

  invoice.invoice_items.build(
    description: "Wedding Cake (medium tier)",
    quantity:    1,
    unit_price:  price_of.call("Wedding Cake (medium tier)")
  )
  invoice.invoice_items.build(
    description: "Chicken Pilau (per plate)",
    quantity:    50,
    unit_price:  price_of.call("Chicken Pilau (per plate)")
  )
  invoice.invoice_items.build(
    description: "Chapati (dozen)",
    quantity:    10,
    unit_price:  price_of.call("Chapati (dozen)")
  )
  invoice.invoice_items.build(
    description: "Passion Juice (per litre)",
    quantity:    8,
    unit_price:  price_of.call("Passion Juice (per litre)")
  )

  invoice.save!
  puts "✓ Sample invoice: #{invoice.invoice_number}, total KES #{invoice.total}"
end

puts "Done. Boot with: bin/dev"
