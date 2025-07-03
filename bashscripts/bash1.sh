#!/bin/bash

# Set your org alias if needed
ORG_ALIAS="ApexSpecialist"

# Query TraceFlag

echo "Getting TraceFlag..."
sfdx force:data:soql:query \\
  -q "SELECT Id FROM Account LIMIT 1" \\
  -r csv -u $ORG_ALIAS >  ./logs/

echo "Done! Files saved:"
