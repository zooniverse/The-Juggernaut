atom_feed(:schema_date => @favourites.first.created_at) do |feed|
  feed.title("Favourites for #{ @user.zooniverse_user_id }")
  feed.updated(@favourites.first.created_at)
  
  @favourites.each do |favourite|
    feed.entry(favourite, :url => public_user_favourite_url(:id => favourite.id, :user_id => @user.id)) do |entry|
      entry.title(favourite.subject.external_ref)
      entry.content(image_tag(favourite.subject.location), :type => 'html')
      entry.author do |author|
        author.name(@user.zooniverse_user_id)
      end
    end
  end
end
