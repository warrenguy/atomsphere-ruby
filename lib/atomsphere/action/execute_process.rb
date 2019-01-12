module Atomsphere
  module Action
    class ExecuteProcess < Action
      required :atom_id
      one_of :process_id, :process_name

      def request
        {
          ProcessProperties: {
            '@type': 'ProcessProperties',
            ProcessProperty: [
              {
                '@type': '',
                Name: 'priority',
                Value: 'medium'
              }
            ]
          },
          atomId: atom_id
        }.merge(!process_id.nil? ?
          { processId: process_id } :
          { processName: process_name })
      end
    end
  end
end
