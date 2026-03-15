class ReflectionsController < ApplicationController
  def index
    @reflections = Reflection.all
  end

  def show
    @reflection = Reflection.find(params[:id])
  end

  def new
    @reflection = Reflection.new
  end

  def create
    @reflection = Reflection.new(create_params)
    @reflection.user = Current.user

    @page = Page.new(number: 1, body: "", pageable_type: "Reflection",
                     pageable_id: @reflection.id)
    @reflection.page = @page

    if @reflection.save && @page.save
      redirect_to @reflection
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @reflection = Reflection.find(destroy_params)
    if @reflection.destroy
      redirect_to root_path, success: "#{@reflection.name} deleted succesfully!"
    else
      redirect_to root_path, alert: "#{@reflection.name} not deleted for some error."
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
end
