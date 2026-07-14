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

  test "body preserves leading and trailing newlines" do
    page = pages(:book_page_one)
    page.body = "\n\nHello\n\n"
    page.valid?
    assert_equal "\n\nHello\n\n", page.body
  end

  test "body preserves 4+ consecutive newlines" do
    page = pages(:book_page_one)
    page.body = "Hello\n\n\n\nWorld"
    page.valid?
    assert_equal "Hello\n\n\n\nWorld", page.body
  end

  test "body preserves 3 consecutive newlines" do
    page = pages(:book_page_one)
    page.body = "Hello\n\n\nWorld"
    page.valid?
    assert_equal "Hello\n\n\nWorld", page.body
  end

  test "body preserves 2 consecutive newlines" do
    page = pages(:book_page_one)
    page.body = "Hello\n\nWorld"
    page.valid?
    assert_equal "Hello\n\nWorld", page.body
  end

  test "body preserves mixed newline content" do
    page = pages(:book_page_one)
    page.body = "\n\nLine 1\n\n\nLine 2\n\n"
    page.valid?
    assert_equal "\n\nLine 1\n\n\nLine 2\n\n", page.body
  end

  test "body preserves 5 consecutive newlines" do
    page = pages(:book_page_one)
    page.body = "Hello\n\n\n\n\nWorld"
    page.valid?
    assert_equal "Hello\n\n\n\n\nWorld", page.body
  end

  test "body preserves single newlines" do
    page = pages(:book_page_one)
    page.body = "Line 1\nLine 2\nLine 3"
    page.valid?
    assert_equal "Line 1\nLine 2\nLine 3", page.body
  end

  test "body handles blank body" do
    page = pages(:book_page_one)
    page.body = ""
    page.valid?
    assert_equal "", page.body
  end

  test "body handles nil body" do
    page = pages(:book_page_one)
    page.body = nil
    page.valid?
    assert_nil page.body
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
