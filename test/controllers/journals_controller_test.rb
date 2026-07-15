require "test_helper"

class JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @journal = documents(:journal_one)
  end

  test "show when authenticated" do
    sign_in_as @user
    get journal_path(@journal)
    assert_response :success
    assert_match @journal.name, response.body
  end

  test "show when unauthenticated redirects to login" do
    get journal_path(@journal)
    assert_redirected_to new_session_path
  end

  test "new when authenticated" do
    sign_in_as @user
    get new_journal_path
    assert_response :success
  end

  test "create when authenticated" do
    sign_in_as @user
    assert_difference("Journal.count") do
      post journals_path, params: { journal: { name: "New Journal" } }
    end
    assert_redirected_to Journal.last
    assert_equal "New Journal", Journal.last.name
  end

  test "create when unauthenticated redirects to login" do
    post journals_path, params: { journal: { name: "New Journal" } }
    assert_redirected_to new_session_path
  end

  test "create with invalid params renders new" do
    sign_in_as @user
    post journals_path, params: { journal: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy when authenticated" do
    sign_in_as @user
    assert_difference("Journal.count", -1) do
      delete journal_path(@journal)
    end
    assert_redirected_to root_path
  end

  test "destroy when unauthenticated redirects to login" do
    delete journal_path(@journal)
    assert_redirected_to new_session_path
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
