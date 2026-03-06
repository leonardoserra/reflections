class JournalsController < ApplicationController
  def index
    @journals = Journal.all
  end

  def show
    @journal = Journal.find(params[:id])
  end

  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(journal_params)
    @journal.user = Current.user
    if @journal.save
      redirect_to @journal
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def journal_params
      params.expect(journal: [ :name ])
    end
end
