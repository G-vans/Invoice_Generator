class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = Product.active.order(:name)
    @products = @products.by_category(params[:category]) if params[:category].present?
    @products = Product.search(params[:search]) if params[:search].present?
    @categories = Product.where.not(category: [ nil, "" ]).distinct.pluck(:category).sort
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.active = true

    if @product.save
      redirect_to products_path, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Product updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :category, :active)
  end
end
