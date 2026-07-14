require "test_helper"

class ReflectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @reflection = documents(:reflection_one)
  end

  test "index when authenticated" do
    sign_in_as @user
    get reflections_path
    assert_response :success
  end

  test "index when unauthenticated redirects to login" do
    get reflections_path
    assert_redirected_to new_session_path
  end

  test "show when authenticated" do
    sign_in_as @user
    get reflection_path(@reflection)
    assert_response :success
    assert_match @reflection.name, response.body
  end

  test "show when unauthenticated redirects to login" do
    get reflection_path(@reflection)
    assert_redirected_to new_session_path
  end

  test "new when authenticated" do
    sign_in_as @user
    get new_reflection_path
    assert_response :success
  end

  test "create when authenticated" do
    sign_in_as @user
    assert_difference("Reflection.count") do
      post reflections_path, params: { reflection: { name: "New Reflection" } }
    end
    assert_redirected_to Reflection.last
    assert_equal "New Reflection", Reflection.last.name
  end

  test "create when unauthenticated redirects to login" do
    post reflections_path, params: { reflection: { name: "New Reflection" } }
    assert_redirected_to new_session_path
  end

  test "create with invalid params renders new" do
    sign_in_as @user
    post reflections_path, params: { reflection: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy when authenticated" do
    sign_in_as @user
    assert_difference("Reflection.count", -1) do
      delete reflection_path(@reflection)
    end
    assert_redirected_to root_path
  end

  test "destroy when unauthenticated redirects to login" do
    delete reflection_path(@reflection)
    assert_redirected_to new_session_path
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
