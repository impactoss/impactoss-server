# frozen_string_literal: true
class ActionsController < ApplicationController
  def new
    @action = Action.new
    # authorize @action
  end

  def index
    @actions = policy_scope(Action.order(:title).page(params[:page]))
    authorize @actions
  end

  def edit
    @action = Action.find(params[:id])
    authorize @action
  end

  def update
    @action = Action.find(params[:id])
    authorize @action

    if @action.update_attributes(permitted_attributes(@action))
      redirect_to action_path, notice: "Action updated"
    else
      render :edit
    end
  end

  def show
    @action = Action.find(params[:id])
    authorize @action
  end

  def destroy
    @action = Action.find(params[:id])
    authorize @action

    if @action.destroy
      redirect_to actions_path, notice: "Action deleted"
    else
      redirect_to actions_path, notice: "Unable to delete Action"
    end
  end
end
