class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.integer :number, default: 1
      t.text :body, default: ""
      t.datetime :page_date
      t.string :place
      t.belongs_to :pageable, polymorphic: true, null: false, index: true

      t.timestamps
    end
    add_index :pages, [ :number, :pageable_id ], unique: true
    add_index :pages, [ :pageable_type, :pageable_id ],
              unique: true,
              where: "pageable_type = 'Reflection'",
              name: "index_pages_unique_on_reflection"
  end
end
