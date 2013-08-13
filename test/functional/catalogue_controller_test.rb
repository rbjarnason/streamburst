require File.dirname(__FILE__) + '/../test_helper'
require 'catalogue_controller'

# Re-raise errors caught by the controller.
class CatalogueController; def rescue_action(e) raise e end; end

class CatalogueControllerTest < Test::Unit::TestCase
  def setup
    @controller = CatalogueController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
