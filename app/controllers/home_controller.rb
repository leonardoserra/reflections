class HomeController < ApplicationController
  def index
    @journals = Journal.where(user: current_user)
    @books = Book.where(user: current_user)
    @reflections = Reflection.where(user: current_user)
  end
end
