class BooksController < DocumentsController
  private

  def model
    Book
  end

  def create_params
    params.expect(model.to_s.downcase.to_sym => [ :name, :author ])
  end

  def update_params
    params.expect(model.to_s.downcase.to_sym => [ :name, :author ])
  end
end
