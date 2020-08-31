class BookmarkSerializer
  include FastVersionedSerializer

  attributes :user_id, :bookmark_type, :title, :view

  set_type :bookmarks
end
