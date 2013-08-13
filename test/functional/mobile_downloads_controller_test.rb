require File.dirname(__FILE__) + '/../test_helper'
require 'mobile_downloads_controller'

# Re-raise errors caught by the controller.
class MobileDownloadsController; def rescue_action(e) raise e end; end

class MobileDownloadsControllerTest < Test::Unit::TestCase
  fixtures :mobile_downloads

  def setup
    @controller = MobileDownloadsController.new
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

    assert_not_nil assigns(:mobile_downloads)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:mobile_download)
    assert assigns(:mobile_download).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:mobile_download)
  end

  def test_create
    num_mobile_downloads = MobileDownload.count

    post :create, :mobile_download => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_mobile_downloads + 1, MobileDownload.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:mobile_download)
    assert assigns(:mobile_download).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil MobileDownload.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      MobileDownload.find(1)
    }
  end
end
