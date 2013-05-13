FactoryGirl.define do
  factory :user do
    forename "John"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "foo@bar.com"
    student_number "000000001"
  end

  factory :user2, :class => User do
    forename "Jim"
    surename  "Doe"
    password "foo"
    password_confirmation "foo"
    email "bar@foo.com"
    student_number "000000002"
  end

  factory :user3, :class => User do
    forename "Jack"
    surename  "Doe"
    password "foo"
    password_confirmation "foo"
    email "bar@bar.com"
    student_number "000000003"
  end

  factory :admin, :class => User do
    forename "Brian"
    surename  "Doe"
    password "foobar"
    password_confirmation "foobar"
    email "admin@example.com"
    student_number "000000005"
    admin true
  end

  factory :registration do
    topic "Beerguide"
    active true
    repository  "https://github.com/uu/foobar"
  end

  factory :old_registration, :class => Registration do
    topic "Waterguide"
    repository  "https://github.com/aa/wasser"
  end

  factory :course do
    year 2013
    name "Ohjelmoinnin harjoitustyo"
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



