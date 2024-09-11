class PageSerializer
  include FastVersionedSerializer

  attributes :title, :content, :menu_title, :order, :draft, :is_archive

  set_type :pages
end
