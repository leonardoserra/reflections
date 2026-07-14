require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "name is required" do
    user = User.new(name: nil, email_address: "test@example.com", password: "secret")
    assert user.invalid?
    assert user.errors[:name].include?("can't be blank")
  end

  test "email_address is required" do
    user = User.new(name: "Test", email_address: nil, password: "secret")
    assert user.invalid?
    assert user.errors[:email_address].include?("can't be blank")
  end

  test "valid user passes validation" do
    user = User.new(name: "Test", email_address: "test@example.com", password: "secret")
    assert user.valid?
  end
end
