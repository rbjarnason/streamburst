require File.dirname(__FILE__) + '/../test_helper'
require 'bids_controller'

# Re-raise errors caught by the controller.
class BidsController; def rescue_action(e) raise e end; end

class BidsControllerTest < Test::Unit::TestCase
  fixtures :bids

  def setup
    @controller = BidsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:bids)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:bids)
    assert assigns(:bids).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:bids)
  end

  def test_create
    num_bids = Bid.count

    post :create, :bids => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_bids + 1, Bid.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:bids)
    assert assigns(:bids).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Bids.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Bids.find(1)
    }
  end
end
