require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "creating a new book" do
    visit root_url

    click_on "New Book"

    fill_in "Name", with: "THE TEST BOOK"

    click_on "Create Book"

    assert_text "THE TEST BOOK"
  end

  private
  private

    def login_as(user)
      visit new_session_url

      find("#email_address", wait: 2).fill_in(with: user.email_address)

      fill_in "password", with: "password"

      click_button "Sign in"

      assert_selector "h2", text: "Your Books:", wait: 2
    end
end
