require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @journal = documents(:journal_one)
    @page = pages(:journal_page_one)
  end

  test "create when authenticated adds page to journal" do
    sign_in_as @user
    assert_difference("Page.count") do
      post pages_path, params: { page: { pageable_id: @journal.id } }
    end
    assert_redirected_to polymorphic_path(@journal, page: 2)
  end

  test "create when unauthenticated redirects to login" do
    post pages_path, params: { page: { pageable_id: @journal.id } }
    assert_redirected_to new_session_path
  end

  test "create for reflection redirects with alert" do
    sign_in_as @user
    reflection = documents(:reflection_one)
    post pages_path, params: { page: { pageable_id: reflection.id } }
    assert_redirected_to reflection
  end

  test "update via turbo stream succeeds" do
    sign_in_as @user
    patch page_path(@page), params: { page: { body: "Updated body" } },
          headers: { accept: "text/vnd.turbo-stream.html" }
    assert_response :ok
    assert_equal "Updated body", @page.reload.body
  end

  test "update via turbo stream with invalid body renders errors" do
    sign_in_as @user
    patch page_path(@page), params: { page: { body: "x" * 1501 } },
          headers: { accept: "text/vnd.turbo-stream.html" }
    assert_response :ok
    assert_not_equal "x" * 1501, @page.reload.body
  end

  test "update when unauthenticated redirects to login" do
    patch page_path(@page), params: { page: { body: "Updated" } }
    assert_redirected_to new_session_path
  end
end
