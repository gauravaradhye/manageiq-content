#
# Description: This class checks to see if the refresh has completed
#
module ManageIQ
  module Automate
    module Service
      module Generic
        module StateMachines
          module GenericLifecycle
            class CheckRefreshed
              def initialize(handle = $evm)
                @handle = handle
              end

              def main
                @handle.log("info", "Starting Check Refreshed")
                check_refreshed(service)
                @handle.log("info", "Ending Check Refreshed")
              end

              private

              def task
                @handle.root["service_template_provision_task"].tap do |task|
                  if task.nil?
                    @handle.log(:error, 'service_template_provision_task is nil')
                    raise "service_template_provision_task not found"
                  end
                end
              end

              def service
                task.destination.tap do |service|
                  if service.nil?
                    @handle.log(:error, 'Service is nil')
                    raise 'Service not found'
                  end
                end
              end

              def check_refreshed(service)
                done, message = service.check_refreshed(@handle.root['service_action'])
                if done
                  if message.blank?
                    @handle.root['ae_result'] = 'ok'
                  else
                    @handle.root['ae_result'] = 'error'
                    @handle.root['ae_reason'] = message
                    task.miq_request.user_message = message
                  end
                else
                  @handle.root['ae_result'] = 'retry'
                end
              end
            end
          end
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  ManageIQ::Automate::Service::Generic::StateMachines::GenericLifecycle::CheckRefreshed.new.main
end
