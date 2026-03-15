class ReflectionsController < ApplicationController
  def index
    @reflections = Reflection.where(user: current_user)
  end

  def show
    @reflection = Reflection.find_by!(id: params[:id], user: current_user)
  end

  def new
    @reflection = Reflection.new
  end

  def create
    @reflection = Reflection.new(create_params)
    @reflection.user = current_user

    @page = Page.new(number: 1, body: "", pageable_type: "Reflection",
                     pageable_id: @reflection.id)
    @reflection.page = @page

    if @reflection.save && @page.save
      redirect_to @reflection, notice: success_create
    else
      render :new, status: :unprocessable_entity, alert: error_create
    end
  end

  def destroy
    @reflection = Reflection.find_by!(id: destroy_params, user: current_user)
    if @reflection.destroy
      redirect_to root_path, notice: success_destroy
    else
      redirect_to root_path, alert: error_destroy
    end
  end

  private
    def create_params
      params.expect(reflection: [ :name ])
    end

    def destroy_params
      params.expect(:id)
    end

    def page_number
      params[:page_number] || 1
    end

    def success_create
       "Reflection \"#{@reflection.name}\" created succesfully!"
    end

    def error_create
      "Reflection \"#{@reflection.name}\" not created for some error."
    end

    def success_destroy
       "Reflection \"#{@reflection.name}\" deleted succesfully!"
    end

    def error_destroy
      "Reflection \"#{@reflection.name}\" not deleted for some error."
    end
end
