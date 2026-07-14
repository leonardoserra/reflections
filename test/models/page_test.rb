require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "body length is limited" do
    page = pages(:book_page_one)
    page.body = "x" * 1501
    assert page.invalid?
    assert page.errors[:body].any?
  end

  test "body length at limit is valid" do
    page = pages(:book_page_one)
    page.body = "x" * 1500
    assert page.valid?
  end

  test "number is required" do
    page = pages(:book_page_one)
    page.number = nil
    assert page.invalid?
    assert page.errors[:number].any?
  end

  test "number must be non-negative" do
    page = pages(:book_page_one)
    page.number = -1
    assert page.invalid?
    assert page.errors[:number].any?
  end

  test "number zero is valid" do
    page = pages(:book_page_one)
    page.number = 0
    assert page.valid?
  end

  test "reflection can have only one page" do
    reflection = documents(:reflection_one)
    page = Page.new(number: 2, body: "Duplicate", pageable: reflection)
    assert page.invalid?
    assert page.errors[:pageable_type].any?
  end

  test "journal_page? returns true for journal pages" do
    page = pages(:journal_page_one)
    assert page.journal_page?
  end

  test "journal_page? returns false for book pages" do
    page = pages(:book_page_one)
    assert_not page.journal_page?
  end

  test "journal_page? returns false for reflection pages" do
    page = pages(:reflection_page)
    assert_not page.journal_page?
  end
end
