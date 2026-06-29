class ExitPage < ApplicationRecord
  belongs_to :question_page, class_name: "Page", optional: false

  validates :heading, presence: true
  validates :markdown, presence: true
end
