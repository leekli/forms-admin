class ReportsController < WebController
  before_action :check_user_has_permission
  after_action :verify_authorized

  def index; end

  def features
    tag = report_tag
    data = feature_report_service(tag:).report

    render template: "reports/features", locals: { tag:, data: }
  end

  def questions_with_answer_type
    tag = report_tag
    answer_type = params.require(:answer_type)
    questions = feature_report_service(tag:).questions_with_answer_type(answer_type)

    if params[:format] == "csv"
      send_data Reports::QuestionsCsvReportService.new(questions).csv,
                type: "text/csv; charset=iso-8859-1",
                disposition: "attachment; filename=#{questions_csv_filename(tag, answer_type)}"
    else
      render template: "reports/questions_with_answer_type", locals: { tag:, answer_type:, questions: }
    end
  end

  def questions_with_add_another_answer
    questions_feature_report_by(tag: report_tag, report: params[:action], method_name: :questions_with_add_another_answer)
  end

  def forms_that_are_copies
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_that_are_copies)
  end

  def forms_with_routes
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_routes, type: :forms_with_routes)
  end

  def forms_with_branch_routes
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_branch_routes, type: :forms_with_routes)
  end

  def forms_with_payments
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_payments)
  end

  def forms_with_exit_pages
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_exit_pages)
  end

  def forms_with_csv_submission_email_attachments
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_csv_submission_email_attachments)
  end

  def forms_with_json_submission_email_attachments
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_json_submission_email_attachments)
  end

  def forms_with_daily_submission_csv
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_daily_submission_csv)
  end

  def forms_with_weekly_submission_csv
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_weekly_submission_csv)
  end

  def forms_with_s3_submissions
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_s3_submissions)
  end

  def forms_with_welsh_translation
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_welsh_translation)
  end

  def forms_with_copy_of_answers_enabled
    forms_feature_report_by(tag: report_tag, report: params[:action], method_name: :forms_with_copy_of_answers_enabled)
  end

  def users
    data = Reports::UsersReportService.new.user_data

    render locals: { data: }
  end

  def add_another_answer
    data = Reports::AddAnotherAnswerUsageService.new.add_another_answer_forms

    render template: "reports/add_another_answer", locals: { data: }
  end

  def last_signed_in_at; end

  def selection_questions_summary
    tag = report_tag
    data = Reports::SelectionQuestionService.new(form_documents(tag:)).statistics

    render template: "reports/selection_questions_summary", locals: { tag:, data: }
  end

  def selection_questions_with_autocomplete
    questions_feature_report_by(
      tag: report_tag,
      report: params[:action],
      method_name: :selection_questions_with_autocomplete,
      type: :selection_questions,
    )
  end

  def selection_questions_with_radios
    questions_feature_report_by(
      tag: report_tag,
      report: params[:action],
      method_name: :selection_questions_with_radios,
      type: :selection_questions,
    )
  end

  def selection_questions_with_checkboxes
    questions_feature_report_by(
      tag: report_tag,
      report: params[:action],
      method_name: :selection_questions_with_checkboxes,
      type: :selection_questions,
    )
  end

  def selection_questions_with_none_of_the_above
    questions_feature_report_by(
      tag: report_tag,
      report: params[:action],
      method_name: :selection_questions_with_none_of_the_above,
      type: :selection_questions_with_none_of_the_above,
    )
  end

  def live_forms_csv
    forms = form_documents(tag: "live-or-archived")

    send_data Reports::FormsCsvReportService.new(forms).csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_forms_report')}"
  end

  def live_questions_csv
    questions = feature_report_service(tag: "live-or-archived").questions

    send_data Reports::QuestionsCsvReportService.new(questions).csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_questions_report')}"
  end

  def contact_for_research
    data = Reports::ContactForResearchService.new.contact_for_research_data

    render locals: { data: }
  end

private

  def report_tag
    params[:tag]
  end

  def form_documents(tag:)
    Reports::FormDocumentsService.form_documents(tag:)
  end

  def feature_report_service(tag:)
    Reports::FeatureReportService.new(form_documents(tag:))
  end

  def forms_feature_report_by(tag:, report:, method_name:, type: :forms)
    forms = feature_report_service(tag:).public_send(method_name)
    forms_feature_report(tag, report, forms, type:)
  end

  def questions_feature_report_by(tag:, report:, method_name:, type: :questions)
    questions = feature_report_service(tag:).public_send(method_name)
    questions_feature_report(tag, report, questions, type:)
  end

  def questions_feature_report(tag, report, questions, type: :questions)
    if params[:format] == "csv"
      send_data Reports::QuestionsCsvReportService.new(questions).csv,
                type: "text/csv; charset=iso-8859-1",
                disposition: "attachment; filename=#{csv_filename("#{tag}_#{report}_report")}"
    else
      render template: "reports/feature_report", locals: { tag:, report:, records: questions, type: }
    end
  end

  def forms_feature_report(tag, report, forms, type: :forms)
    if params[:format] == "csv"
      send_data Reports::FormsCsvReportService.new(forms).csv,
                type: "text/csv; charset=iso-8859-1",
                disposition: "attachment; filename=#{csv_filename("#{tag}_#{report}_report")}"
    else
      render template: "reports/feature_report", locals: { tag:, report:, records: forms, type: }
    end
  end

  def check_user_has_permission
    authorize :report, :can_view_reports?
  end

  def questions_csv_filename(tag, answer_type)
    base_name = "#{tag}_questions_report"
    base_name += "_#{answer_type}_answer_type" if answer_type.present?
    csv_filename(base_name)
  end

  def csv_filename(base_name)
    "#{base_name}-#{Time.zone.now.utc.utc.strftime("%Y%m%dT%H%M%SZ")}.csv"
  end
end
