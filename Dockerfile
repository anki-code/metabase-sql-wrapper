FROM metabase/metabase:v0.36.6
RUN apk update && apk add --update py-pip && pip install xonsh
ADD run.xsh /
RUN chmod +x run.xsh
ENTRYPOINT ["/usr/bin/xonsh", "/run.xsh"]

