module ForemanSalt
  module Concerns
    module HostgroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :load_vars_for_ajax, :salt_modules
      end

      def salt_environment_selected
        @hostgroup = Hostgroup.authorized(:view_hostgroups, Hostgroup).find_by_id(params[:hostgroup_id]) || Hostgroup.new(params[:hostgroup])

        if params[:hostgroup][:salt_environment_id].present?
          @salt_environment = ::ForemanSalt::SaltEnvironment.friendly.find(params[:hostgroup][:salt_environment_id])
          load_vars_for_ajax
          render :partial => 'foreman_salt/salt_modules/host_tab_pane'
        else
          logger.info 'environment_id is required to render states'
        end
      end

      private

      def load_vars_for_ajax_with_salt_modules
        load_vars_for_ajax_without_salt_modules
        @obj = @hostgroup
        @salt_environment ||= @hostgroup.salt_environment

        if @salt_environment
          @inherited_salt_modules = @salt_environment.salt_modules.where(:id => @hostgroup.inherited_salt_modules)
          @salt_modules           = @salt_environment.salt_modules - @inherited_salt_modules
        else
          @inherited_salt_modules = @salt_modules = []
        end

        @selected = @hostgroup.salt_modules || []
      end
    end
  end
end
