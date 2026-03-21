class DocumentsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to "new_#{model.to_s.downcase}".to_sym, alert: "Too many creations at once." },
             unless: -> { Rails.env.test? }

  def index
    @documents = model.where(user: current_user)
  end

  def show
    @document = model.find_by!(id: params[:id], user: current_user)
  end

  def new
    @document = model.new
  end

  def create
    @document = model.new(create_params)
    @document.user = current_user

    @page = Page.new(number: 1, pageable_type: model,
                     pageable_id: @document.id)

    # Book and Journal has_many pages
    # Reflection has_one page
    if @document.respond_to?(:pages)
      @document.pages << @page
    else
      @document.page = @page
    end

    if @document.save && @page.save
      redirect_to @document, notice: success_create
    else
      render :new, status: :unprocessable_entity, alert: error_create
    end
  end

  def destroy
    @document = model.find_by!(id: destroy_params, user: current_user)
    if @document.destroy
      redirect_to root_path, notice: success_destroy
    else
      redirect_to root_path, alert: error_destroy
    end
  end

  private

    def model
      Document
    end

    def create_params
      params.expect(model.to_s.downcase.to_sym => [ :name ])
    end

    def destroy_params
      params.expect(:id)
    end

    def page_number
      params[:page_number] || 1
    end

    def success_create
       "#{model} \"#{@document.name}\" created succesfully!"
    end

    def error_create
      "#{model} \"#{@document.name}\" not created for some error."
    end

    def success_destroy
       "#{model} \"#{@document.name}\" deleted succesfully!"
    end

    def error_destroy
      "#{model} \"#{@document.name}\" not deleted for some error."
    end
end
