xml.instruct!
xml.favourites do |favourites|
  @favourites.each do |favourite|
    favourites.favourite do |f|
      f.id             favourite.id
      f.created_on     favourite.created_at
      f.subject_id       favourite.subject.id
      f.subject_location favourite.subject.location
      f.external_ref   favourite.subject.external_ref
    end
  end
end
