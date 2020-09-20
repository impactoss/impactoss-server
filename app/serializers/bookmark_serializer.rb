class BookmarkSerializer
  include FastVersionedSerializer

  attributes :user_id, :title, :view

  set_type :bookmarks
end
