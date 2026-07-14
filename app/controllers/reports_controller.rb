class ReportsController < WebController
  before_action :check_user_has_permission
  after_action :verify_authorized

  def index; end

  def features
    tag = params[:tag]
    forms = Reports::FormDocumentsService.form_documents(tag:)
    data = Reports::FeatureReportService.new(forms).report

    render template: "reports/features", locals: { tag:, data: }
  end

  def questions_with_answer_type
    tag = params[:tag]
    answer_type = params.require(:answer_type)
    forms = Reports::FormDocumentsService.form_documents(tag:)
    questions = Reports::FeatureReportService.new(forms).questions_with_answer_type(answer_type)

    if params[:format] == "csv"
      send_data Reports::QuestionsCsvReportService.new(questions).csv,
                type: "text/csv; charset=iso-8859-1",
                disposition: "attachment; filename=#{questions_csv_filename(tag, answer_type)}"
    else
      render template: "reports/questions_with_answer_type", locals: { tag:, answer_type:, questions: }
    end
  end

  def questions_with_add_another_answer
    render_feature_report(:questions_with_add_another_answer, kind: :questions)
  end

  def forms_that_are_copies
    render_feature_report(:forms_that_are_copies, kind: :forms)
  end

  def forms_with_routes
    render_feature_report(:forms_with_routes, kind: :forms, type: :forms_with_routes)
  end

  def forms_with_branch_routes
    render_feature_report(:forms_with_branch_routes, kind: :forms, type: :forms_with_routes)
  end

  def forms_with_payments
    render_feature_report(:forms_with_payments, kind: :forms)
  end

  def forms_with_exit_pages
    render_feature_report(:forms_with_exit_pages, kind: :forms)
  end

  def forms_with_csv_submission_email_attachments
    render_feature_report(:forms_with_csv_submission_email_attachments, kind: :forms)
  end

  def forms_with_json_submission_email_attachments
    render_feature_report(:forms_with_json_submission_email_attachments, kind: :forms)
  end

  def forms_with_daily_submission_csv
    render_feature_report(:forms_with_daily_submission_csv, kind: :forms)
  end

  def forms_with_weekly_submission_csv
    render_feature_report(:forms_with_weekly_submission_csv, kind: :forms)
  end

  def forms_with_s3_submissions
    render_feature_report(:forms_with_s3_submissions, kind: :forms)
  end

  def forms_with_welsh_translation
    render_feature_report(:forms_with_welsh_translation, kind: :forms)
  end

  def forms_with_copy_of_answers_enabled
    render_feature_report(:forms_with_copy_of_answers_enabled, kind: :forms)
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
    tag = params[:tag]
    forms = Reports::FormDocumentsService.form_documents(tag:)
    data = Reports::SelectionQuestionService.new(forms).statistics

    render template: "reports/selection_questions_summary", locals: { tag:, data: }
  end

  def selection_questions_with_autocomplete
    render_feature_report(:selection_questions_with_autocomplete, kind: :questions, type: :selection_questions)
  end

  def selection_questions_with_radios
    render_feature_report(:selection_questions_with_radios, kind: :questions, type: :selection_questions)
  end

  def selection_questions_with_checkboxes
    render_feature_report(:selection_questions_with_checkboxes, kind: :questions, type: :selection_questions)
  end

  def selection_questions_with_none_of_the_above
    render_feature_report(:selection_questions_with_none_of_the_above, kind: :questions, type: :selection_questions_with_none_of_the_above)
  end

  def live_forms_csv
    forms = Reports::FormDocumentsService.form_documents(tag: "live-or-archived")

    send_data Reports::FormsCsvReportService.new(forms).csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_forms_report')}"
  end

  def live_questions_csv
    forms = Reports::FormDocumentsService.form_documents(tag: "live-or-archived")
    questions = Reports::FeatureReportService.new(forms).questions

    send_data Reports::QuestionsCsvReportService.new(questions).csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_questions_report')}"
  end

  def contact_for_research
    data = Reports::ContactForResearchService.new.contact_for_research_data

    render locals: { data: }
  end

private

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

  def render_feature_report(feature_method, kind:, type: nil)
    tag = params[:tag]
    forms = Reports::FormDocumentsService.form_documents(tag:)
    records = Reports::FeatureReportService.new(forms).send(feature_method)

    if kind == :forms
      forms_feature_report(tag, params[:action], records, type: type || :forms)
    else
      questions_feature_report(tag, params[:action], records, type: type || :questions)
    end
  end

  def questions_csv_filename(tag, answer_type)
    base_name = "#{tag}_questions_report"
    base_name += "_#{answer_type}_answer_type" if answer_type.present?
    csv_filename(base_name)
  end

  def csv_filename(base_name)
    "#{base_name}-#{Time.zone.now}.csv"
  end
end
