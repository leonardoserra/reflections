require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @journal = documents(:journal_one)
    @reflection = documents(:reflection_one)
    @other_book = documents(:book_one)
  end

  test "bulk_destroy when authenticated deletes own documents" do
    sign_in_as @user
    assert_difference("Document.count", -2) do
      post bulk_destroy_documents_path, params: { document_ids: [ @journal.id, @reflection.id ] }
    end
    assert_redirected_to root_path
    assert_match "Deleted 2 documents", flash[:notice]
  end

  test "bulk_destroy when authenticated ignores other users documents" do
    sign_in_as @user
    assert_difference("Document.count", -1) do
      post bulk_destroy_documents_path, params: { document_ids: [ @journal.id, @other_book.id ] }
    end
    assert_redirected_to root_path
    assert_match "Deleted 1 document", flash[:notice]
  end

  test "bulk_destroy when authenticated with empty ids does nothing" do
    sign_in_as @user
    assert_no_difference("Document.count") do
      post bulk_destroy_documents_path, params: { document_ids: [] }
    end
    assert_redirected_to root_path
    assert_match "Deleted 0 documents", flash[:notice]
  end

  test "bulk_destroy when unauthenticated redirects to login" do
    post bulk_destroy_documents_path, params: { document_ids: [ @journal.id ] }
    assert_redirected_to new_session_path
  end
end
