xml.instruct!
xml.favourite do |favourite|
  favourite.id             @favourite.id
  favourite.created_on     @favourite.created_at
  favourite.subject_id       @favourite.subject.id
  favourite.subject_location @favourite.subject.location
end
