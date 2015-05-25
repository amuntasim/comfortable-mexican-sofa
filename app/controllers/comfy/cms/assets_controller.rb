class Comfy::Cms::AssetsController < Comfy::Cms::BaseController
  skip_before_action :verify_authenticity_token

  before_action :load_asset,
                :use_null_session

  after_action :set_cache_control_header

  def render_css
    css = @cms_layout ? @cms_layout.css : @cms_file.content_cache
    render :text => css, :content_type => 'text/css'
  end

  def render_js
    js = @cms_layout ? @cms_layout.js : @cms_file.content_cache
    render :text => js, :content_type => 'application/javascript'
  end

  protected

    # The asset is specified via <tt>params[:identifier]</tt>.
    # It can be either a identifier for a layout from which we then load css or js
    # or it can be a file name. Remember that because Rails does not support
    # dots in url id segments the file name contains hypens instead of dots.
    def load_asset
      if is_file?
        unless @cms_file = @cms_site.files.find_by_slug(params[:identifier])
          render :nothing => true, :status => 404
        end
      else
        unless @cms_layout = @cms_site.layouts.find_by_identifier(params[:identifier])
          render :nothing => true, :status => 404
        end
      end
    end

    # Checks if *params[:identifier]* is a file identifier.
    def is_file?
      params[:identifier].last(4) == '-css' || params[:identifier].last(3) == '-js'
    end

    # null_session avoids cookies and flash updates
    def use_null_session
      ActionController::RequestForgeryProtection::ProtectionMethods::NullSession.new(self)
        .handle_unverified_request
    end

    def set_cache_control_header
      if params[:cache_buster].present?
        response.headers['Cache-Control'] = "public, max-age=#{1.year.to_i}"
      end
    end
end
