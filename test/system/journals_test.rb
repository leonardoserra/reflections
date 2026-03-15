require "application_system_test_case"

class JournalsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "creating a new journal" do
    visit root_url

    click_on "NEW JOURNAL"

    fill_in "Name", with: "THE TEST JOURNAL"

    send_keys(:enter)

    assert :ok
  end

  private

    def login_as(user)
      visit new_session_url

      find("#email_address").fill_in(with: user.email_address)

      fill_in "password", with: "password"

      click_button "Sign in"

      assert :ok
      assert_selector "h2", text: "Your Journals"
    end
end
