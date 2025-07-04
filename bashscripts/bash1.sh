#!/bin/bash

# Set your org alias if needed
ORG_ALIAS="ApexSpecialist"

# Query TraceFlag

echo "Getting TraceFlag..."
sfdx force:data:soql:query -q "Select ID from traceFlag" -t  > /Users/tdash/Desktop/projects/Apex-SuperBadge/logs/Traceflag.log
echo "Done! Files saved:"
