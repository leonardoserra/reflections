class DocumentsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to "new_#{model.to_s.downcase}".to_sym, alert: "Too many creations at once." },
             unless: -> { Rails.env.test? }

  def index
    @documents = model.where(user: current_user)
  end

  def show
    @document = model.find_by!(id: params[:id], user: current_user)

    @total_pages = @document.ordered_pages.count
    page_number = (params[:page] || @document.bookmark).to_i
    @current_page = @document.ordered_pages.find_by(number: page_number) || @document.ordered_pages.first

    redirect_to root_path, alert: "No pages found for this document." and return if @current_page.nil?

    @document.update_column(:bookmark, @current_page.number) if params[:page].present?
  end

  def new
    @document = model.new
  end

  def create
    @document = model.new(create_params)
    @document.user = current_user

    ApplicationRecord.transaction do
      @document.save!
      if model == Reflection
        @document.create_page!(number: 1)
      else
        @document.pages.create!(number: 1)
      end
    end

    redirect_to @document, notice: success_create
  rescue ActiveRecord::RecordInvalid => e
    @document.errors.add(:base, e.record.errors.full_messages.to_sentence) if e.record != @document
    render :new, status: :unprocessable_entity
  end

  def edit
    @document = model.find_by!(id: params[:id], user: current_user)
  end

  def update
    @document = model.find_by!(id: params[:id], user: current_user)
    if @document.update(update_params)
      redirect_to @document, notice: success_update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document = model.find_by!(id: params[:id], user: current_user)
    if @document.destroy
      redirect_to root_path, notice: success_destroy
    else
      redirect_to root_path, alert: error_destroy
    end
  end

  def bulk_destroy
    ids = Array(params[:document_ids])
    documents = Document.where(id: ids, user: current_user)
    count = documents.size
    documents.destroy_all
    redirect_to root_path, notice: "Deleted #{count} #{'document'.pluralize(count)}."
  end

  private

    def model
      Document
    end

    def create_params
      params.expect(model.to_s.downcase.to_sym => [ :name ])
    end

    def update_params
      params.expect(model.to_s.downcase.to_sym => [ :name ])
    end

    def success_create
       "#{model} \"#{@document.name}\" created successfully!"
    end

    def success_update
      "#{model} \"#{@document.name}\" updated successfully!"
    end

    def success_destroy
       "#{model} \"#{@document.name}\" deleted successfully!"
    end

    def error_destroy
      "#{model} \"#{@document.name}\" could not be deleted."
    end
end
