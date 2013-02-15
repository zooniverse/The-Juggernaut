# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20110216214749) do

  create_table "activities", :force => true do |t|
    t.float    "score"
    t.integer  "counter",            :default => 0
    t.integer  "zooniverse_user_id"
    t.integer  "workflow_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["workflow_id"], :name => "index_activities_on_workflow_id"
  add_index "activities", ["zooniverse_user_id"], :name => "index_activities_on_zooniverse_user_id"

  create_table "annotations", :force => true do |t|
    t.text     "value"
    t.integer  "task_id"
    t.integer  "answer_id"
    t.integer  "classification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["answer_id"], :name => "index_annotations_on_answer_id"
  add_index "annotations", ["classification_id"], :name => "index_annotations_on_classification_id"
  add_index "annotations", ["task_id"], :name => "index_annotations_on_task_id"

  create_table "answers", :force => true do |t|
    t.string   "value"
    t.text     "details"
    t.integer  "score"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["task_id"], :name => "index_answers_on_task_id"

  create_table "classifications", :force => true do |t|
    t.string   "locale"
    t.integer  "total_score"
    t.datetime "started"
    t.datetime "ended"
    t.integer  "workflow_id"
    t.integer  "zooniverse_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classifications", ["workflow_id"], :name => "index_classifications_on_workflow_id"
  add_index "classifications", ["zooniverse_user_id"], :name => "index_classifications_on_zooniverse_user_id"

  create_table "favourites", :force => true do |t|
    t.integer  "zooniverse_user_id"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favourites", ["subject_id"], :name => "index_favourites_on_subject_id"
  add_index "favourites", ["zooniverse_user_id"], :name => "index_favourites_on_zooniverse_user_id"

  create_table "group_members", :force => true do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["group_id"], :name => "index_group_members_on_group_id"
  add_index "group_members", ["member_id"], :name => "index_group_members_on_member_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "public"
    t.integer  "focus_id"
    t.string   "focus_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["focus_id", "focus_type"], :name => "index_groups_on_focus_id_and_focus_type"

  create_table "result_subjects", :force => true do |t|
    t.integer  "subject_id"
    t.integer  "result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "result_subjects", ["result_id"], :name => "index_result_subjects_on_result_id"
  add_index "result_subjects", ["subject_id"], :name => "index_result_subjects_on_subject_id"

  create_table "results", :force => true do |t|
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_classifications", :force => true do |t|
    t.integer  "classification_id"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_classifications", ["classification_id"], :name => "index_subject_classifications_on_classification_id"
  add_index "subject_classifications", ["subject_id"], :name => "index_subject_classifications_on_subject_id"

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "thumbnail_location"
    t.integer  "classification_count", :default => 0
    t.text     "external_ref"
    t.float    "average_score"
    t.boolean  "active"
    t.integer  "workflow_id"
    t.string   "zooniverse_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["active"], :name => "index_subjects_on_active"
  add_index "subjects", ["classification_count"], :name => "index_subjects_on_classification_count"
  add_index "subjects", ["workflow_id"], :name => "index_subjects_on_workflow_id"
  add_index "subjects", ["zooniverse_id"], :name => "index_subjects_on_zooniverse_id"

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.integer  "count"
    t.boolean  "has_defined_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trainings", :force => true do |t|
    t.integer  "stage",              :default => 0
    t.integer  "zooniverse_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trainings", ["zooniverse_user_id"], :name => "index_trainings_on_zooniverse_user_id"

  create_table "workflow_answers", :force => true do |t|
    t.integer  "answer_id"
    t.integer  "workflow_task_id"
    t.integer  "next_workflow_task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_answers", ["answer_id"], :name => "index_workflow_answers_on_answer_id"
  add_index "workflow_answers", ["workflow_task_id"], :name => "index_workflow_answers_on_workflow_task_id"

  create_table "workflow_tasks", :force => true do |t|
    t.integer  "task_id"
    t.integer  "parent_id"
    t.integer  "workflow_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_tasks", ["parent_id"], :name => "index_workflow_tasks_on_parent_id"
  add_index "workflow_tasks", ["task_id"], :name => "index_workflow_tasks_on_task_id"
  add_index "workflow_tasks", ["workflow_id"], :name => "index_workflow_tasks_on_workflow_id"

  create_table "workflows", :force => true do |t|
    t.string   "name"
    t.text     "details"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflows", ["default"], :name => "index_workflows_on_default"

  create_table "zooniverse_users", :force => true do |t|
    t.integer  "zooniverse_user_id"
    t.string   "api_key"
    t.string   "name"
    t.boolean  "admin",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zooniverse_users", ["zooniverse_user_id"], :name => "index_zooniverse_users_on_zooniverse_user_id"

end
