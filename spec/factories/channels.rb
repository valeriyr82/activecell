FactoryGirl.define do
  factory :channel do
    sequence(:name) { |n| "Channel #{n}" }
  end

  factory :channel_segment_mix do
    segment
    distribution 1.0
  end
end
