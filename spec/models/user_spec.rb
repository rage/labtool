require "spec_helper"

describe User do
  it "student number can not be blank" do
    u = User.create

    u.should_not be_valid
  end

  it "student number should be a number" do
    u = User.create :student_number => 'abc'

    u.should_not be_valid
  end
end