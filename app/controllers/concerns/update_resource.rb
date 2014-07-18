module UpdateResource
  def update_resource resource, resource_params, options = {}
    options.assert_valid_keys :stale_location

    resource.update resource_params
  rescue ActiveRecord::StaleObjectError
    redirect_to options[:stale_location] || [:edit, resource], alert: t('.stale', scope: :flash)
  end
end
