function kipexist {

  ip_to_test=""
  if [ ! -z $(echo $1| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b") ];then
    ip_to_test="$1"
    echo "ip_to search $1"
  else
    echo "arg 1 not a valid ip stdout everything"
  fi
  list_ns=$(kubectl get ns |awk '{print $1}' | grep -Ev "kube*|default|NAME")

  # search in pods
  for ns in $(echo -e "$list_ns") ;do
    pods_ip=$(kubectl -n "$ns"  get pod --output=json|jq '.items[] | "\(.spec.containers[].name)    \(.spec.nodeName)   \(.status.hostIP)    \(.status.podIP)"')

    if [ -z "${ip_to_test}" ];then
        >&2 echo "namespace $ns"
       echo -e "${pods_ip}"
    else
      match=$(echo "${pods_ip}" | grep -E "$ip_to_test")
      if [ ! -z "${match}" ];then
        echo "PODS: namespace $ns"
        echo "$match"
      fi
    fi
  done
  # search in services
  for ns in $(echo -e "$list_ns") ;do
    svc_ip=$(kubectl -n $ns get svc --output=json|jq '.items[] | "\(.metadata.name)    \(.spec.clusterIP)"'| grep -v "none")
    if [ -z "${ip_to_test}" ];then
        >&2 echo "namespace $ns"
       echo -e "${svc_ip}"

 else
      match=$(echo "${svc_ip}" | grep -E "$ip_to_test")
      if [ ! -z "${match}" ];then
        echo "SVC: namespace $ns"
        echo "$match"
      fi
    fi
  done

  #search in ingress
   for ns in $(echo -e "$list_ns") ;do
    ing_ip=$( kubectl -n $ns get ing --output=json|jq '.items[] | "\(.metadata.name)    \(.status.loadBalancer.ingress[].ip)"'| grep -v "none")

    if [ -z "${ip_to_test}" ];then
        >&2 echo "namespace $ns"
       echo -e "${ing_ip}"
    else
      match=$(echo "${ing_ip}" | grep -E "$ip_to_test")
      if [ ! -z "${match}" ];then
        echo "INGRESS: namespace $ns"
        echo "$match"
      fi
    fi
  done

   for ns in $(echo -e "$list_ns") ;do
    endpoint=$(kubectl -n $ns get endpoints)

    if [ -z "${ip_to_test}" ];then
        >&2 echo "namespace $ns"
       echo -e "${endpoint}"
    else
 match=$(echo "${endpoint}" | grep -E "$ip_to_test")
      if [ ! -z "${match}" ];then
        echo "ENDPOINT namespace $ns"
        echo "$match"
      fi
    fi
  done
}

