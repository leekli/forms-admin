class Forms::BrandInput < BaseInput
  BrandOption = Struct.new(:id, :name)

  attr_accessor :form, :brand_id

  validates :brand_id, inclusion: { in: ->(input) { input.allowed_brand_ids } }, allow_blank: true

  def brands
    organisation = form.group&.organisation
    return Brand.none if organisation.nil?

    organisation.brands
  end

  def allowed_brand_ids
    brands.map(&:slug)
  end

  def brand_options
    default_option = BrandOption.new("", I18n.t("helpers.label.forms_brand_input.brand_id.options.default"))
    [default_option] + brands.map { |brand| BrandOption.new(brand.slug, brand.name) }
  end

  def submit
    return false if invalid?

    form.brand_id = brand_id.presence
    form.save_draft!
  end

  def assign_form_values
    self.brand_id = form.brand_id.to_s
    self
  end
end
