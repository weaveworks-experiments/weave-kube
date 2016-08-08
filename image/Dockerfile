FROM weaveworks/plugin:kube-test
ADD ./weaver ./launch.sh ./kube-peers /home/weave/
ADD weavedata.db /weavedb/
COPY ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/home/weave/launch.sh"]
