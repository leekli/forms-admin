module Organisations
  class FilterInput < BaseInput
    attr_accessor :name, :mou_signed

    def has_filters?
      [name, mou_signed].any?(&:present?)
    end

    def mou_signed_options
      [
        OpenStruct.new(label: I18n.t("organisations.index.filter.mou_signed.any")),
        OpenStruct.new(label: I18n.t("organisations.boolean.true"), value: "true"),
        OpenStruct.new(label: I18n.t("organisations.boolean.false"), value: "false"),
      ]
    end
  end
end
