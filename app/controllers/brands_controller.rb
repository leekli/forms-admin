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

private

  def brand_params
    params.require(:brand).permit(:name, :slug)
  end
end
