class BooksController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_book_path, alert: "Too many creations at once." }, unless: -> { Rails.env.test? }
  def index
    @books = Book.where(user: current_user)
  end

  def show
    @book = Book.find_by!(id: params[:id], user: current_user)
    @page_number = page_number
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(create_params)
    @book.user = current_user

    @page = Page.new(number: 1, body: "", pageable_type: "Book",
                     pageable_id: @book.id)
    @book.pages << @page

    if @book.save && @page.save
      redirect_to @book, notice: success_create
    else
      render :new, status: :unprocessable_entity, alert: error_create
    end
  end

  def destroy
    @book = Book.find_by!(id: destroy_params, user: current_user)
    if @book.destroy
      redirect_to root_path, notice: success_destroy
    else
      redirect_to root_path, alert: error_destroy
    end
  end

  private
    def create_params
      params.expect(book: [ :name ])
    end

    def destroy_params
      params.expect(:id)
    end

    def page_number
      params[:page_number] || 1
    end

    def success_create
       "Book \"#{@book.name}\" created succesfully!"
    end

    def error_create
      "Book \"#{@book.name}\" not created for some error."
    end

    def success_destroy
       "Book \"#{@book.name}\" deleted succesfully!"
    end

    def error_destroy
      "Book \"#{@book.name}\" not deleted for some error."
    end
end
