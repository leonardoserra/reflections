require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @book = documents(:book_one)
  end

  test "show when authenticated" do
    sign_in_as @user
    get book_path(@book)
    assert_response :success
    assert_match @book.name, response.body
  end

  test "show when unauthenticated redirects to login" do
    get book_path(@book)
    assert_redirected_to new_session_path
  end

  test "new when authenticated" do
    sign_in_as @user
    get new_book_path
    assert_response :success
  end

  test "create when authenticated" do
    sign_in_as @user
    assert_difference("Book.count") do
      post books_path, params: { book: { name: "New Book", author: "Author" } }
    end
    assert_redirected_to Book.last
    assert_equal "New Book", Book.last.name
    assert_equal "Author", Book.last.author
  end

  test "create when unauthenticated redirects to login" do
    post books_path, params: { book: { name: "New Book", author: "Author" } }
    assert_redirected_to new_session_path
  end

  test "create with invalid params renders new" do
    sign_in_as @user
    post books_path, params: { book: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy when authenticated" do
    sign_in_as @user
    assert_difference("Book.count", -1) do
      delete book_path(@book)
    end
    assert_redirected_to root_path
  end

  test "destroy when unauthenticated redirects to login" do
    delete book_path(@book)
    assert_redirected_to new_session_path
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
