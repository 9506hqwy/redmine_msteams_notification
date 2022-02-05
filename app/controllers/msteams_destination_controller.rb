# frozen_string_literal: true

class MsteamsDestinationController < ApplicationController
  before_action :find_project_by_project_id, :authorize

  def test
    destination = @project.msteams_destination || MsteamsDestination.new
    user = User.current

    card  = destination.card_class
    message = card.new('test', 'test notification', nil)

    assigned_to = user.name
    if message.mention_available?
      assigned_to = message.add_mention_for(user)
    end

    message.add_section(nil, nil, {
                          l(:field_assigned_to) => assigned_to.to_s
                        })

    Rails.logger.debug(message.get_json)

    begin
      if destination.url.present?
        message.send(destination.url, destination.skip_ssl_verify)
        flash[:notice] = l(:notice_successful_test)
      end
    rescue => e
      flash[:error] = l(:error_failure_test) + e.message
    end

    redirect_to settings_project_path(@project, tab: :msteams_notification)
  end

  def update
    destination = @project.msteams_destination || MsteamsDestination.new
    destination.project = @project
    destination.url = params[:msteams_destination]
    destination.format = params[:msteams_format]
    destination.skip_ssl_verify = params[:msteams_skip_ssl_verify].present?

    if destination.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to settings_project_path(@project, tab: :msteams_notification)
    else
      redirect_to settings_project_path(@project)
    end
  end
end
