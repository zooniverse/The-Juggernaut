require 'factory_girl'

Factory.sequence :name do |n|
  n
end

Factory.define :subject do |a|
  a.after_build           { |subject| subject.name = "Subject #{ Factory.next(:name) }" }
  a.location              "http://imageserver.org/subjects/1"
  a.classification_count  0
  a.external_ref          "123456789"
  a.zooniverse_id         "AJZ123456"
end

Factory.define :admin_user, :class => ZooniverseUser do |u|
  u.after_build           { |user| user.zooniverse_user_id = Factory.next(:name) }
  u.after_build           { |user| user.name = "User #{ Factory.next(:name) }" }
  u.api_key               "12345"
  u.admin                 true
end

Factory.define :zooniverse_user do |u|
  u.api_key               "123456"
  u.admin                 false
  u.after_build           { |user| user.name = "User #{ Factory.next(:name) }" }
  u.after_build           { |user| user.zooniverse_user_id = Factory.next(:name) }
end

Factory.define :classification do |c|
  c.zooniverse_user       { |user| user.association(:zooniverse_user) }
  c.annotations           { |annotation| [annotation.association(:annotation)] }
  c.subjects                { |subject| [subject.association(:subject)] }
  c.workflow              { |workflow| workflow.association(:workflow) }
  c.locale                'en'
  c.started               Time.now
  c.ended                 Time.now
end

Factory.define :annotation do |a|
  a.task                  { |task| task.association(:task) }
  a.value                 "Spiral"
  a.answer                { |answer| answer.association(:answer) }
end

Factory.define :favourite do |f|
  f.subject                 { |subject| subject.association(:subject) }
  f.zooniverse_user       { |user| user.association(:zooniverse_user) }
end

Factory.define :answer do |r|
  r.value                 "Spiral"
  r.score                 1
end

Factory.define :task do |t|
  t.after_build           { |task| task.name = "Task #{ Factory.next(:name) }" }
  t.count                 1
  t.answers               { |answer| [answer.association(:answer)] }
end

Factory.define :workflow do |w|
  w.after_build           { |workflow| workflow.name = "Workflow #{ Factory.next(:name) }" }
  w.details               "My workflow details"
  w.default               true
  w.workflow_tasks        { |workflow_task| [workflow_task.association(:workflow_task)] }
end

Factory.define :workflow_task do |t|
  t.task                  { |task| task.association(:task) }
  t.workflow_answers      { |workflow_answer| [workflow_answer.association(:workflow_answer)] }
end

Factory.define :workflow_answer do |a|
  a.answer                { |answer| answer.association(:answer) }
end

Factory.define :subject_group, :class => Group do |g|
  g.after_build           { |group| group.name = "SubjectGroup #{ Factory.next(:name) }" }
  g.description           "A group of users around an subject"
  g.focus                 { |group| group.association(:subject) }
end

Factory.define :zooniverse_user_group, :class => Group do |g|
  g.after_build           { |group| group.name = "ZooniverseUserGroup #{ Factory.next(:name) }" }
  g.description           "A group of users around a zooniverse user"
  g.focus                 { |group| group.association(:zooniverse_user) }
end

Factory.define :result do |r|
  r.value                 "Blah"
end
