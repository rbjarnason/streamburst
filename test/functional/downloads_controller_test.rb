require File.dirname(__FILE__) + '/../test_helper'
require 'downloads_controller'

# Re-raise errors caught by the controller.
class DownloadsController; def rescue_action(e) raise e end; end

class DownloadsControllerTest < Test::Unit::TestCase
  fixtures :downloads

  def setup
    @controller = DownloadsController.new
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

    assert_not_nil assigns(:downloads)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:download)
    assert assigns(:download).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:download)
  end

  def test_create
    num_downloads = Download.count

    post :create, :download => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_downloads + 1, Download.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:download)
    assert assigns(:download).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Download.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Download.find(1)
    }
  end
end
