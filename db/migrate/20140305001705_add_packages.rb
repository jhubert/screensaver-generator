class AddPackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :email_address
      t.string :name
      t.text   :quotes
      t.boolean :paid, default: false
      t.timestamps
    end
  end
end
