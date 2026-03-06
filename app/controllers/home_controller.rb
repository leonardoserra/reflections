class HomeController < ApplicationController
  def index
    @journals = Journal.all
    @books = Book.all
    @reflections = Reflection.all
  end
end
