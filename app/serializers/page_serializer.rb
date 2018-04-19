class PageSerializer
  include FastApplicationSerializer

  attributes :title, :content, :menu_title, :order, :draft

  set_type :pages
end
