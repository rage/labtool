FactoryGirl.define do
  factory :user do
    forename "John"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "foo@bar.com"
    student_number 1
  end

  factory :user2, :class => User do
    forename "Jim"
    surename  "Doe"
    password "foo"
    password_confirmation "foo"
    email "bar@foo.com"
    student_number 2
  end

  factory :user3, :class => User do
    forename "Jack"
    surename  "Doe"
    password "foo"
    password_confirmation "foo"
    email "bar@bar.com"
    student_number 3
  end

  factory :admin, :class => User do
    forename "Brian"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "admin@example.com"
    student_number 5
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



