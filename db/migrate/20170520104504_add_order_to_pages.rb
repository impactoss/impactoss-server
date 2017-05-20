class AddOrderToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :order, :integer
  end
end
