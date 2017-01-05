class CategoriesController < ApplicationController
  def new
    @category = Category.new
    authorize @category

    @taxonomy = Taxonomy.find(params[:taxonomy_id])
    authorize @taxonomy
  end

  def create
    @taxonomy = Taxonomy.find(params[:taxonomy_id])
    authorize @taxonomy

    @category = Category.new
    authorize @category

    if @taxonomy.categories.create(permitted_attributes(@category))
      redirect_to taxonomy_path(@taxonomy), notice: 'Category created'
    else
      render :new
    end
  end

  def edit
    @category = category.find(params[:category_id])
    authorize @category
  end

  def update
    @category = category.find(params[:category_id])
    authorize @category

    if @category.update_attributes(permitted_attributes(@category))
      redirect_to taxonomy_path, notice: 'category updated'
    else
      render :edit
    end
  end

  def show
    @category = category.find(params[:id])
    authorize @category
  end

  def destroy
    @category = category.find(params[:id])
    authorize @category

    if @category.destroy
      redirect_to categorys_path, notice: 'category deleted'
    else
      redirect_to categorys_path, notice: 'Unable to delete category'
    end
  end
end
