class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.integer :number
      t.text :body
      t.belongs_to :pageable, polymorphic: true

      t.timestamps
    end
  end
end
