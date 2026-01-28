FactoryBot.define do
  factory :progress_report do
    association :indicator
    association :due_date
    title { "MyString" }
    description { "MyText" }
    document_url { "MyString" }
    document_public { false }
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
