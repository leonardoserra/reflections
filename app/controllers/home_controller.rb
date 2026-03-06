class HomeController < ApplicationController
  def index
    @journals = Journal.all
  end
end
