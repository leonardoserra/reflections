class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.integer :number, null: false
      t.text :body
      t.belongs_to :pageable, polymorphic: true, null: false, index: true

      t.timestamps
    end
  end
end
