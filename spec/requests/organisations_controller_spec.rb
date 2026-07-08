require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  shared_examples "unauthorized user is forbidden" do
    context "when the user is not a super admin" do
      before do
        login_as_standard_user

        get path
      end

      it "returns http code 403 and renders forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response).to render_template("errors/forbidden")
      end
    end
  end

  describe "#index" do
    let(:path) { organisations_path }

    let!(:organisation) { create :organisation, slug: "department-for-testing" }
    let!(:closed_organisation) { create :organisation, slug: "closed-department", closed: true }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200 and renders the index view" do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("organisations/index")
      end

      it "lists all organisations, including closed ones" do
        expect(response.body).to include(organisation.name)
        expect(response.body).to include(closed_organisation.name)
      end
    end
  end

  describe "#show" do
    let(:organisation) { create :organisation, :with_org_admin, slug: "department-for-testing" }
    let(:path) { organisation_path(organisation) }

    let!(:organisation_domain) { create :organisation_domain, organisation: }

    include_examples "unauthorized user is forbidden"

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user

        get path
      end

      it "returns http code 200 and renders the show view" do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("organisations/show")
      end

      it "shows the organisation's configuration" do
        expect(response.body).to include(organisation.name)
        expect(response.body).to include(organisation.slug)
        expect(response.body).to include(organisation.admin_users.first.email)
        expect(response.body).to include(I18n.t("mou_signatures.index.agreement_type.#{organisation.mou_signatures.first.agreement_type}"))
        expect(response.body).to include(organisation_domain.domain)
      end
    end
  end
end
