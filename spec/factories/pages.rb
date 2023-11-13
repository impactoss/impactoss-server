FactoryBot.define do
  factory :page do
    title { "MyString" }
    content { "MyText" }
    menu_title { "MyString" }
    draft { false }
  end
end
