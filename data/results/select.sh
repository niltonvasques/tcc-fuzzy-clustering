LINE=1; 
grep "Correctly Classified Instances" -r --include=*.weka | grep nsf | while read line ; do 
  if [ $LINE -eq 1 ]; then 
    TP=$(echo $line | awk '{print $5}')
    CLUSTER=$(echo $line | cut -f1 -d-)
    CLASSIFIER=$(echo $line | cut -f2 -d/ | cut -f1 -d.)
    echo "TP: "$TP" CLUSTER: "$CLUSTER" CLASSIFIER: "$CLASSIFIER 
    LINE=0
  else 
    LINE=$((LINE+1)) 
  fi
done
