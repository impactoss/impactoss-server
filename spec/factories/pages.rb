FactoryBot.define do
  factory :page do
    title { "MyString" }
    content { "MyText" }
    menu_title { "MyString" }
    draft { false }

    trait :is_archive do
      is_archive { true }
    end

    trait :draft do
      draft { true }
    end

    trait :published do
      draft { false }
    end
  end
end
