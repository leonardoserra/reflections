class PagesController < ApplicationController
  before_action :set_page

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
