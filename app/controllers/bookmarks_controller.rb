class BookmarksController < ApplicationController
  #before_action :authenticate_user!

  before_action :set_and_authorize_user, only: [:show, :update, :destroy]

  # GET /bookmarks
  def index
    @bookmarks = policy_scope(base_object).order(created_at: :desc)
    #authorize @users

    render json: serialize(@bookmarks)
  end

  # GET /bookmarks/1
  def show
    render json: serialize(@bookmark)
  end

  # POST /bookmarks
  def create
    @bookmark = Bookmark.new
    @bookmark.assign_attributes(permitted_attributes(@bookmark))
    authorize @bookmark

    if @bookmark.save
      render json: serialize(@bookmark), status: :created, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bookmarks/1
  def update
    render json: serialize(@bookmark) if @bookmark.update_attributes!(permitted_attributes(@bookmark))
  end

  # DELETE /bookmarks/1
  def destroy
    @bookmark.destroy
  end

  private

  def base_object
    Bookmark
  end

  def serialize(target, serializer: BookmarkSerializer)
    super
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user
    @bookmark = policy_scope(base_object).find(params[:id])
    authorize @bookmark
  end
end
