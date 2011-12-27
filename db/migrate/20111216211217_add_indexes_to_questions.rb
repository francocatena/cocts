class AddIndexesToQuestions < ActiveRecord::Migration
  def self.up
    if DB_ADAPTER == 'PostgreSQL'
      # Índice para utilizar búsqueda full text (por el momento sólo en español)
      execute "CREATE INDEX index_questions_on_code_and_question ON questions USING gin(to_tsvector('spanish', coalesce(code,'') || ' ' || coalesce(question,'')))"
    else
      add_index :questions, :code
      add_index :questions, :question
    end
  end

  def self.down
    if DB_ADAPTER == 'PostgreSQL'
      execute 'DROP INDEX index_questions_on_code_and_question'
    else
      remove_index :questions, :column => :code
      remove_index :questions, :column => :question
    end
  end
end
