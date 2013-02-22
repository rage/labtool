FactoryGirl.define do
  factory :user do
    forename "John"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "foo@bar.com"
    student_number 1
  end

  factory :admin, :class => User do
    forename "Brian"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "admin@example.com"
    student_number 2
    admin true
  end

  factory :registration do
    topic "Beerguide"
    repository  "http://www.github.com/foobar"
  end

  factory :old_registration, :class => Registration do
    topic "Waterguide"
    repository  "http://www.github.com/wasser"
  end

  factory :course do
    year 2013
    period "periodi III"
    review_round 0
    week 1
    state 0
    active true
  end

  factory :inactive_course, :class => Course do
    year 2013
    period "periodi II"
    review_round 1
    week 1
    state 1
    active false
  end
end



