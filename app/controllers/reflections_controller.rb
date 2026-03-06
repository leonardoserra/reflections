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
    @reflection = Reflection.new(reflection_params)
    @reflection.user = Current.user
    if @reflection.save
      redirect_to @reflection
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def reflection_params
      params.expect(reflection: [ :name ])
    end
end
