FactoryGirl.define do
  factory :progress_report do
    indicator_id 1
    due_date_id 1
    title 'MyString'
    description 'MyText'
    document_url 'MyString'
    document_public false
    draft false
  end
end
