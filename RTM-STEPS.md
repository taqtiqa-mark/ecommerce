# RTM-Port

```bash
podman build --build-arg RUBY_VERSION=3.1.0 \
             --build-arg DISTRO_NAME=bullseye \
             --build-arg PG_MAJOR=14 \
             --build-arg NODE_MAJOR=16 \
             --build-arg YARN_VERSION=1.22.17 \
             --tag ecommerce .
podman pod rm servers
podman pod create --name servers \
                  --publish=5432:5432 \
                  --publish=3000:3000 \
                  --share cgroup,ipc,net,uts
pushd rails_application
podman build --tag ecommerce-db .
podman run -dt --pod servers --rm -v $(pwd):/app ecommerce-db
popd
podman run -it --pod servers --rm -v $(pwd):/app ecommerce /bin/bash
root@servers:# make install
root@servers:# # Yes, run this twice....
root@servers:# make install
root@servers:# pushd rails_application
root@servers:# make dev
root@servers:# rails db:drop
root@servers:# rails db:create
root@servers:# rails db:schema:dump
root@servers:# pushd db/migrate
root@servers:# mv -f ./../structure.sql structure.sql.bak
root@servers:# for v in $(ls *.rb|cut -d _ -f 1| xargs echo);
root@servers:# do
root@servers:#     rails db:migrate VERSION=$v;
root@servers:#     rails db:schema:dump;
root@servers:#     mv -f ./../structure.sql V${v}_structure.sql;
root@servers:# done
root@servers:# rails db:drop
root@servers:# rails db:create

```
