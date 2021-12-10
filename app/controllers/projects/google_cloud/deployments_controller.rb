# frozen_string_literal: true

class Projects::GoogleCloud::DeploymentsController < Projects::GoogleCloud::BaseController
  def cloud_run
    render json: { "hello" => "world" }
  end

  def cloud_storage
    render json: { "foo" => "bar" }
  end
end
