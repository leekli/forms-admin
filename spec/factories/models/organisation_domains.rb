FactoryBot.define do
  factory :organisation_domain do
    organisation { association :organisation, slug: "test-org" }
    domain { Faker::Internet.domain_name }
  end
end
