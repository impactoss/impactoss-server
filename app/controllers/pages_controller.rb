class PagesController < ApplicationController
  before_action :set_and_authorize_page, only: [:show, :update, :destroy]

  # GET /pages
  def index
    @pages = policy_scope(base_object).order(created_at: :desc)
    authorize @pages

    render json: serialize(@pages)
  end

  # GET /pages/1
  def show
    render json: serialize(@page)
  end

  # POST /pages
  def create
    @page = Page.new
    @page.assign_attributes(permitted_attributes(@page))
    authorize @page

    if @page.save
      render json: serialize(@page), status: :created, location: @page
    else
      render json: @page.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pages/1
  def update
    if params[:page][:updated_at] && DateTime.parse(params[:page][:updated_at]).to_i != @page.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @page.update_attributes!(permitted_attributes(@page))
      set_and_authorize_page
      render json: serialize(@page)
    end
  end

  # DELETE /pages/1
  def destroy
    @page.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_page
    @page = policy_scope(base_object).find(params[:id])
    authorize @page
  end

  def base_object
    Page
  end

  def serialize(target, serializer: PageSerializer)
    super
  end
end
