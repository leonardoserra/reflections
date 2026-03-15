class JournalsController < ApplicationController
  def index
    @journals = Journal.where(user: current_user)
  end

  def show
    @journal = Journal.find_by!(id: params[:id], user: current_user)
  end

  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(create_params)
    @journal.user = current_user

    @page = Page.new(number: 1, body: "", pageable_type: @journal,
                     pageable_id: @journal.id)
    @journal.pages << @page

    if @journal.save && @page.save
      redirect_to @journal, notice: success_create
    else
      render :new, status: :unprocessable_entity, alert: error_create
    end
  end

  def destroy
    @journal = Journal.find_by!(id: destroy_params, user: current_user)

    if @journal.destroy!
      redirect_to root_path, notice: success_destroy
    else
      redirect_to root_path, alert: error_destroy
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

    def success_create
       "Journal \"#{@journal.name}\" created succesfully!"
    end

    def error_create
      "Journal \"#{@journal.name}\" not created for some error."
    end

    def success_destroy
       "Journal \"#{@journal.name}\" deleted succesfully!"
    end

    def error_destroy
      "Journal \"#{@journal.name}\" not deleted for some error."
    end
end
