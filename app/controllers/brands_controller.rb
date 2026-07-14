class BrandsController < WebController
  after_action :verify_authorized

  def index
    authorize Brand, :can_view_brands?

    @brands = Brand.order(:name).load
  end

  def show
    authorize Brand, :can_view_brands?

    @brand = Brand.find(params[:id])
  end

  def new
    authorize Brand, :can_edit_brands?

    @brand = Brand.new
  end

  def create
    authorize Brand, :can_edit_brands?

    @brand = Brand.new(brand_params)

    if @brand.save
      redirect_to @brand, success: t("brands.success_messages.create")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize Brand, :can_edit_brands?

    @brand = Brand.find(params[:id])
  end

  def update
    authorize Brand, :can_edit_brands?

    @brand = Brand.find(params[:id])

    if @brand.update(update_brand_params)
      redirect_to @brand, success: t("brands.success_messages.update"), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

private

  def brand_params
    params.require(:brand).permit(:name, :slug)
  end

  def update_brand_params
    params.require(:brand).permit(:name)
  end
end
