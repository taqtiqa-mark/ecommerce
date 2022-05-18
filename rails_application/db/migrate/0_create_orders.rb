class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    # enable_sql_logging do
      create_table :orders do |t|
        t.string :uid
        t.string :number
        t.string :customer
        t.string :state
      end
    # end
  end
end
