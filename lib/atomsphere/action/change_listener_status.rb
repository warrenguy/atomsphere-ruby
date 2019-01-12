module Atomsphere
  module Action
    class ChangeListenerStatus < Action
      required :listener_id, :container_id, :action

      def request
        Hash[fields.map{ |f| [f, send(f)] }]
      end
    end
  end
end
