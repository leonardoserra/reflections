class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.integer :number, default: 1
      t.text :body, default: ""
      t.belongs_to :pageable, polymorphic: true, null: false, index: true

      t.timestamps
    end
    add_index :pages, [:number, :pageable_id], unique: true
  end
end
