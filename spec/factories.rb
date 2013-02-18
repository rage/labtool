FactoryGirl.define do
  factory :user do
    forename "John"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "foo@bar.com"
    student_number 1
  end

  # This will use the User class (Admin would have been guessed)
  factory :registration do
    repository  "http://www.github.com/foobar"
    association :user
  end
end



