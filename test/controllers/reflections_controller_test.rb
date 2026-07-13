require "test_helper"

class ReflectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @reflection = documents(:reflection_one)
  end

  test "edit when authenticated" do
    sign_in_as @user

    get edit_reflection_path(@reflection)

    assert_response :success
    assert_match @reflection.name, response.body
  end

  test "edit when unauthenticated redirects to login" do
    get edit_reflection_path(@reflection)

    assert_redirected_to new_session_path
  end

  test "update with valid params" do
    sign_in_as @user

    patch reflection_path(@reflection), params: { reflection: { name: "Updated Reflection" } }

    assert_redirected_to @reflection
    assert_equal "Updated Reflection", @reflection.reload.name
  end

  test "update with invalid params renders edit" do
    sign_in_as @user

    patch reflection_path(@reflection), params: { reflection: { name: "" } }

    assert_response :unprocessable_entity
    assert_not_equal "", @reflection.reload.name
  end

  test "update when unauthenticated redirects to login" do
    patch reflection_path(@reflection), params: { reflection: { name: "New Name" } }

    assert_redirected_to new_session_path
  end
end
