require "test_helper"

class JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @journal = documents(:journal_one)
  end

  test "edit when authenticated" do
    sign_in_as @user

    get edit_journal_path(@journal)

    assert_response :success
    assert_match @journal.name, response.body
  end

  test "edit when unauthenticated redirects to login" do
    get edit_journal_path(@journal)

    assert_redirected_to new_session_path
  end

  test "update with valid params" do
    sign_in_as @user

    patch journal_path(@journal), params: { journal: { name: "Updated Journal" } }

    assert_redirected_to @journal
    assert_equal "Updated Journal", @journal.reload.name
  end

  test "update with invalid params renders edit" do
    sign_in_as @user

    patch journal_path(@journal), params: { journal: { name: "" } }

    assert_response :unprocessable_entity
    assert_not_equal "", @journal.reload.name
  end

  test "update when unauthenticated redirects to login" do
    patch journal_path(@journal), params: { journal: { name: "New Name" } }

    assert_redirected_to new_session_path
  end
end
