require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "name is required" do
    document = Document.new(name: nil, user: users(:one))
    assert document.invalid?
    assert document.errors[:name].include?("can't be blank")
  end

  test "ordered_pages raises NotImplementedError" do
    document = Document.new(name: "Test", user: users(:one))
    assert_raises(NotImplementedError) { document.ordered_pages }
  end
end
