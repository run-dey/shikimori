FactoryGirl.define do
  factory :episode_notification do
    anime nil
    episode 1
    is_raw false
    is_subtitles false
    is_fandub false
  end
end
