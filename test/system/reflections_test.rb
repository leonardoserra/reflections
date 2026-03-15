require "application_system_test_case"

class ReflectionsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "creating a new reflection" do
    visit root_url

    click_on "NEW REFLECTION"

    fill_in "Name", with: "THE TEST REFLECTION"

    send_keys(:enter)

    assert :ok
    assert_text 'Reflection "THE TEST REFLECTION" created succesfully!'
  end

  private

    def login_as(user)
      visit new_session_url

      find("#email_address").fill_in(with: user.email_address)

      fill_in "password", with: "password"

      click_button "Sign in"

      assert :ok
      assert_selector "h2", text: "Your Reflections"
    end
end
