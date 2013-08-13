require File.dirname(__FILE__) + '/../test_helper'
require 'discount_vouchers_controller'

# Re-raise errors caught by the controller.
class DiscountVouchersController; def rescue_action(e) raise e end; end

class DiscountVouchersControllerTest < Test::Unit::TestCase
  def setup
    @controller = DiscountVouchersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
