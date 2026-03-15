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
    @journal = Journal.new(create_params)
    @journal.user = Current.user
    @page = Page.new(number: 1, body: "", pageable_type: @journal,
                     pageable_id: @journal.id)
    @journal.pages << @page

    if @journal.save && @page.save
      redirect_to @journal
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @journal = Journal.find(destroy_params)
    if @journal.destroy
      redirect_to root_path, success: "#{@journal.name} deleted succesfully!"
    else
      redirect_to root_path, alert: "#{@journal.name} not deleted for some error."
    end
  end

  private
    def create_params
      params.expect(journal: [ :name ])
    end

    def destroy_params
      params.expect(:id)
    end

    def page_number
      params[:page_number] || 1
    end
end
