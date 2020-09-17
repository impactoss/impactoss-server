class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_and_authorize_bookmark, only: [:update, :destroy]
  skip_after_action :verify_authorized, only: [:show]

  def forbidden
    render json: {error: 'Forbidden'}, status: 403
  end

  # GET /bookmarks
  def index
    @bookmarks = policy_scope(base_object)
      .where(user_id: current_user.id)
      .order(created_at: :desc)
    authorize @bookmarks

    render json: serialize(@bookmarks)
  end

  # GET /bookmarks/[id]
  def show
    policy_scope(base_object)

    forbidden
  end

  # POST /bookmarks
  def create
    @bookmark = Bookmark.new
    @bookmark.assign_attributes(permitted_attributes(@bookmark))

    @bookmark[:view] = params[:bookmark][:view]
    @bookmark[:user_id] = current_user.id
    authorize @bookmark

    if @bookmark.save
      render json: serialize(@bookmark), status: :created, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # PUT /bookmarks/[id]
  def update
    @bookmark[:view] = params[:bookmark][:view]
    render json: serialize(@bookmark) if @bookmark.update_attributes!(permitted_attributes(@bookmark))
  end

  # DELETE /bookmarks/[id]
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

    if @bookmark.user_id != current_user.id
      return forbidden
    end

    authorize @bookmark
  end
end
