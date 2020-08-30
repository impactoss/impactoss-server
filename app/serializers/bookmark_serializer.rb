class BookmarkSerializer
  include FastVersionedSerializer

  attributes :title, :view

  set_type :bookmarks
end
