# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120611172001) do

  create_table "answer_instances", :force => true do |t|
    t.integer  "question_instance_id"
    t.integer  "answer_id"
    t.text     "answer_text"
    t.integer  "answer_category"
    t.string   "valuation",              :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
    t.float    "attitudinal_assessment"
  end

  add_index "answer_instances", ["answer_id"], :name => "index_answer_instances_on_answer_id"
  add_index "answer_instances", ["question_instance_id"], :name => "index_answer_instances_on_question_instance_id"

  create_table "answers", :force => true do |t|
    t.integer  "category"
    t.integer  "order"
    t.text     "clarification"
    t.text     "answer"
    t.integer  "question_id"
    t.integer  "lock_version",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "project_instances", :force => true do |t|
    t.string   "first_name"
    t.string   "professor_name"
    t.string   "email"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "identifier"
    t.text     "description"
    t.integer  "year"
    t.integer  "project_type"
    t.date     "valid_until"
    t.text     "forms"
    t.integer  "age"
    t.string   "country"
    t.string   "degree"
    t.text     "profession_ocuppation"
    t.text     "profession_certification"
    t.string   "student_status"
    t.string   "teacher_status"
    t.string   "teacher_level"
    t.string   "genre"
    t.integer  "study_subjects"
    t.text     "degree_school"
    t.text     "degree_university"
    t.text     "study_subjects_choose"
    t.text     "educational_center_city"
    t.text     "educational_center_name"
    t.text     "study_subjects_different"
    t.text     "group_type"
    t.text     "group_name"
    t.string   "plausible_attitude_index"
    t.string   "adecuate_attitude_index"
    t.string   "naive_attitude_index"
  end

  add_index "project_instances", ["project_id"], :name => "index_project_instances_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "identifier"
    t.text     "description"
    t.integer  "year"
    t.integer  "project_type"
    t.date     "valid_until"
    t.text     "forms"
    t.integer  "lock_version", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "group_name"
    t.text     "group_type"
    t.string   "test_type"
  end

  add_index "projects", ["identifier"], :name => "index_projects_on_identifier", :unique => true

  create_table "projects_questions", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "question_id"
  end

  add_index "projects_questions", ["project_id", "question_id"], :name => "index_projects_questions_on_project_id_and_question_id"

  create_table "projects_teaching_units", :id => false, :force => true do |t|
    t.integer "teaching_unit_id"
    t.integer "project_id"
  end

  add_index "projects_teaching_units", ["project_id"], :name => "index_projects_teaching_units_on_project_id"
  add_index "projects_teaching_units", ["teaching_unit_id"], :name => "index_projects_teaching_units_on_teaching_unit_id"

  create_table "question_instances", :force => true do |t|
    t.integer  "project_instance_id"
    t.integer  "question_id"
    t.text     "question_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_instances", ["project_instance_id"], :name => "index_question_instances_on_project_instance_id"
  add_index "question_instances", ["question_id"], :name => "index_question_instances_on_question_id"

  create_table "questions", :force => true do |t|
    t.integer  "dimension"
    t.string   "code"
    t.text     "question"
    t.integer  "lock_version", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["code"], :name => "index_questions_on_code", :unique => true
  add_index "questions", ["dimension"], :name => "index_questions_on_dimension"

  create_table "questions_teaching_units", :id => false, :force => true do |t|
    t.integer "teaching_unit_id"
    t.integer "question_id"
  end

  add_index "questions_teaching_units", ["question_id"], :name => "index_questions_teaching_units_on_question_id"
  add_index "questions_teaching_units", ["teaching_unit_id"], :name => "index_questions_teaching_units_on_teaching_unit_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subtopics", :force => true do |t|
    t.string   "title"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code"
  end

  add_index "subtopics", ["title"], :name => "index_subtopics_on_title", :unique => true

  create_table "teaching_units", :force => true do |t|
    t.string   "title"
    t.integer  "subtopic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teaching_units", ["title"], :name => "index_teaching_units_on_title", :unique => true

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code"
  end

  add_index "topics", ["title"], :name => "index_topics_on_title", :unique => true

  create_table "users", :force => true do |t|
    t.string   "user"
    t.string   "password"
    t.string   "name"
    t.string   "lastname"
    t.boolean  "enable"
    t.string   "email"
    t.string   "salt"
    t.integer  "lock_version", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.boolean  "private",      :default => false
  end

  add_index "users", ["user"], :name => "index_users_on_user", :unique => true

end
