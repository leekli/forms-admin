require "rails_helper"

describe "organisations/index.html.erb" do
  let(:organisation) { create :organisation, slug: "department-for-testing" }
  let(:closed_organisation) { create :organisation, slug: "closed-department", closed: true }
  let(:organisations) { [organisation, closed_organisation] }
  let(:user_counts) { { organisation.id => 3 } }
  let(:group_counts) { { organisation.id => 2 } }
  let(:organisation_ids_with_mou) { Set.new([organisation.id]) }

  before do
    assign(:organisations, organisations)
    assign(:user_counts, user_counts)
    assign(:group_counts, group_counts)
    assign(:organisation_ids_with_mou, organisation_ids_with_mou)

    render template: "organisations/index"
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: I18n.t("page_titles.organisations"))
  end

  it "contains a scrollable wrapper with a table in it" do
    expect(rendered).to have_css(".app-scrolling-wrapper > table")
  end

  it "links each organisation name to its show page" do
    expect(rendered).to have_link(organisation.name_with_abbreviation, href: organisation_path(organisation))
    expect(rendered).to have_link(closed_organisation.name_with_abbreviation, href: organisation_path(closed_organisation))
  end

  it "contains the organisation slug" do
    expect(rendered).to have_text(organisation.slug)
  end

  it "contains the user and group counts" do
    expect(rendered).to have_xpath "//tbody/tr[1]/td[5]", text: "3"
    expect(rendered).to have_xpath "//tbody/tr[1]/td[6]", text: "2"
  end

  it "shows zero counts for organisations without users or groups" do
    expect(rendered).to have_xpath "//tbody/tr[2]/td[5]", text: "0"
    expect(rendered).to have_xpath "//tbody/tr[2]/td[6]", text: "0"
  end

  it "shows whether an MOU has been signed" do
    expect(rendered).to have_xpath "//tbody/tr[1]/td[7]", text: I18n.t("organisations.boolean.true")
    expect(rendered).to have_xpath "//tbody/tr[2]/td[7]", text: I18n.t("organisations.boolean.false")
  end

  context "when there are no organisations" do
    let(:organisations) { [] }

    it "does not show the table" do
      expect(rendered).not_to have_css("table")
    end
  end
end
