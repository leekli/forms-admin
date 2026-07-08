class OrganisationsController < WebController
  include Pagy::Backend

  after_action :verify_authorized

  def index
    authorize Organisation, :can_view_organisations?

    @pagy, @organisations = pagy(Organisation.order(:name), limit: 50)

    organisation_ids = @organisations.map(&:id)
    @user_counts = User.where(organisation_id: organisation_ids).group(:organisation_id).count
    @form_counts = GroupForm.joins(:group).where(groups: { organisation_id: organisation_ids }).reorder(nil).group("groups.organisation_id").count
    @organisation_ids_with_mou = MouSignature.where(organisation_id: organisation_ids).distinct.pluck(:organisation_id).to_set
  end

  def show
    authorize Organisation, :can_view_organisations?

    @organisation = Organisation.includes(:organisation_domains, mou_signatures: :user).find(params[:id])
  end
end
