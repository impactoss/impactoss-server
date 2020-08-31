class BookmarksController < ApplicationController
  #before_action :authenticate_user!

  before_action :set_and_authorize_bookmark, only: [:show]

  # GET /bookmarks
  def index
    policy_scope(base_object)

    render text: 'Forbidden', status: 403
  end

  # GET /bookmarks/[user-id]
  def show
    @bookmarks = policy_scope(base_object)
      .where(user_id: params[:id])
      .order(created_at: :desc)
    authorize @bookmarks

    render json: serialize(@bookmarks)
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
  def set_and_authorize_bookmark
    @bookmark = policy_scope(base_object).find(params[:id])
    authorize @bookmark
  end
end
