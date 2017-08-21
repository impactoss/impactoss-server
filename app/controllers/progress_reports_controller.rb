# frozen_string_literal: true
class ProgressReportsController < ApplicationController
  before_action :set_and_authorize_progress_report, only: [:show, :update, :destroy]

  # GET /progress_reports
  def index
    @progress_reports = policy_scope(ProgressReport).order(created_at: :desc).page(params[:page])
    authorize @progress_reports

    render json: @progress_reports
  end

  # GET /progress_reports/1
  def show
    render json: @progress_report
  end

  # POST /progress_reports
  def create
    @progress_report = ProgressReport.new
    @progress_report.assign_attributes(permitted_attributes(@progress_report))
    authorize @progress_report

    if @progress_report.save
      render json: @progress_report, status: :created, location: @progress_report
    else
      render json: @progress_report.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /progress_reports/1
  def update
    if params[:progress_report][:updated_at] && DateTime.parse(params[:progress_report][:updated_at]).to_i != @progress_report.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    render json: @progress_report if @progress_report.update_attributes!(permitted_attributes(@progress_report))
  end

  # DELETE /progress_reports/1
  def destroy
    @progress_report.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_progress_report
    @progress_report = policy_scope(ProgressReport).find(params[:id])
    authorize @progress_report
  end
end
