class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.string :invoice_number, null: false
      t.date :invoice_date, null: false
      t.date :due_date, null: false
      t.string :client_name, null: false
      t.text :client_address
      t.string :client_email
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :tax_rate, precision: 5, scale: 2, null: false, default: 0.0
      t.decimal :tax_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0.0
      t.text :notes
      t.string :status, default: "draft"

      t.timestamps
    end
    add_index :invoices, :invoice_number, unique: true
  end
end
