require File.dirname(__FILE__) + '/../test_helper'
require 'heimdall_content_targets_controller'

# Re-raise errors caught by the controller.
class HeimdallContentTargetsController; def rescue_action(e) raise e end; end

class HeimdallContentTargetsControllerTest < Test::Unit::TestCase
  fixtures :heimdall_content_targets

  def setup
    @controller = HeimdallContentTargetsController.new
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

    assert_not_nil assigns(:heimdall_content_targets)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:heimdall_content_target)
    assert assigns(:heimdall_content_target).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:heimdall_content_target)
  end

  def test_create
    num_heimdall_content_targets = HeimdallContentTarget.count

    post :create, :heimdall_content_target => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_heimdall_content_targets + 1, HeimdallContentTarget.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:heimdall_content_target)
    assert assigns(:heimdall_content_target).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil HeimdallContentTarget.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      HeimdallContentTarget.find(1)
    }
  end
end
