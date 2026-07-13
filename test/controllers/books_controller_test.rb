require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @book = documents(:book_one)
  end

  test "edit when authenticated" do
    sign_in_as @user

    get edit_book_path(@book)

    assert_response :success
    assert_match @book.name, response.body
  end

  test "edit when unauthenticated redirects to login" do
    get edit_book_path(@book)

    assert_redirected_to new_session_path
  end

  test "update with valid params" do
    sign_in_as @user

    patch book_path(@book), params: { book: { name: "Updated Book" } }

    assert_redirected_to @book
    assert_equal "Updated Book", @book.reload.name
  end

  test "update with invalid params renders edit" do
    sign_in_as @user

    patch book_path(@book), params: { book: { name: "" } }

    assert_response :unprocessable_entity
    assert_not_equal "", @book.reload.name
  end

  test "update when unauthenticated redirects to login" do
    patch book_path(@book), params: { book: { name: "New Name" } }

    assert_redirected_to new_session_path
  end
end
