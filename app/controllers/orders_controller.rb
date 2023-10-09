class OrdersController < ApplicationController
  before_action :authenticate

  def index
    orders = Orders::IndexQuery.call(order_params)
    identifier = SecureRandom.hex
    Orders::FileGeneratorWorker.perform_async(orders.pluck(:id), identifier)
    render json: { identifier: identifier }, status: :ok
  rescue ActionController::ParameterMissing, Date::Error
    render_bad_request
  end

  private

  def order_params
    raise Date::Error, "no start_date, end_date supplied" if params[:start_date].blank? || params[:end_date].blank?

    params.permit(:start_date, :end_date, :user_name, :sum)
  end

  def render_bad_request
    render json: { "message" => "start_date and end_date parameters are required of format YYYY-MM-DD_HH:mm:ss, " \
                                "optional parameters are user_name:string and sum:float" },
           status: :bad_request
  end
end
