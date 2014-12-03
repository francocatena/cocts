module MandrillHeaders
  extend ActiveSupport::Concern

  included do
    after_action :add_mandrillapp_headers
  end

  private

    def add_mandrillapp_headers
      headers['X-MC-ReturnPathDomain'] = 'mail.cirope.com'
      headers['X-MC-TrackingDomain']   = 'mail.cirope.com'
      headers['X-MC-SigningDomain']    = 'mail.cirope.com'
      headers['X-MC-Subaccount']       = 'cocts'
    end
end
