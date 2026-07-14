class PagesController < ApplicationController
  before_action :set_page, only: :update

  def create
    @pageable = Document.find(params[:page][:pageable_id])
    unless @pageable.user == current_user
      redirect_to root_path, alert: "Not authorized" and return
    end
    if @pageable.is_a?(Reflection)
      redirect_to @pageable, alert: "Cannot add pages to a Reflection." and return
    end
    next_number = (@pageable.pages.maximum(:number) || 0) + 1
    @pageable.pages.create!(number: next_number, body: "")
    redirect_to polymorphic_path(@pageable, page: next_number), notice: "Page added."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: "Could not add page."
  end

  def update
    if @page.update(page_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path, notice: "Page updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path, alert: @page.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_page
    @page = Page.includes(pageable: :user).find(params[:id])
    unless @page.pageable.user == current_user
      redirect_to root_path, alert: "Not authorized" and return
    end
  end

  def page_params
    params.expect(page: [ :body, :page_date, :place ])
  end
end
