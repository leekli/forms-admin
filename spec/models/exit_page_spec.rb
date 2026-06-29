require "rails_helper"

RSpec.describe ExitPage, type: :model do
  it "has a valid factory" do
    expect(build(:exit_page)).to be_valid
  end

  describe "validations" do
    context "when heading is blank" do
      it "is invalid" do
        expect(build(:exit_page, heading: nil)).not_to be_valid
      end
    end

    context "when markdown is blank" do
      it "is invalid" do
        expect(build(:exit_page, markdown: nil)).not_to be_valid
      end
    end
  end

  describe "associations" do
    let!(:question_page) { create(:page) }
    let!(:exit_page) { create(:exit_page, question_page:) }

    it "has a question page" do
      expect(exit_page.question_page).to eq(question_page)
    end

    it "is deleted when the question page is deleted" do
      expect { question_page.destroy! }.to change(described_class, :count).by(-1)
    end

    it "the page has exit pages" do
      expect(question_page.exit_pages).to eq([exit_page])
    end
  end
end
