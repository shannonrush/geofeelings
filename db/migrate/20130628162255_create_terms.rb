class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.string :word
      t.integer :sense_number
      t.float :pos_score      
      t.float :neg_score      
      t.text :glossary

      t.timestamps
    end
  end
end
