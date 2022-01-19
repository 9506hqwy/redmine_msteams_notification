# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects,
           :msteams_destinations

  def test_destroy
    p = projects(:projects_002)
    p.destroy!

    begin
      msteams_destinations(:msteams_destinations_001)
      assert false
    rescue ActiveRecord::RecordNotFound
      assert true
    end
  end
end
