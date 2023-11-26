class CreateSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :songs do |t|
      t.string :link, null: false
      t.string :title
      t.integer :length
      t.decimal :rating
      t.integer :views
      t.integer :state

      t.timestamps
    end
  end
end
