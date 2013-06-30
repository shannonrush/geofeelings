class AddIndexToTermsWords < ActiveRecord::Migration
  def change
    add_index :terms, :word
  end
end
