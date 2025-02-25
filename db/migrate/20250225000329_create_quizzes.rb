class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.string :topic
      t.integer :score

      t.timestamps
    end
  end
end
