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
root@servers:
make install
# Yes, run this twice....
make install
pushd rails_application
make dev
skylight disable_dev_warning
rails db:drop
rails db:create
pushd db/migrate
rm -f ./../structure.sql
rm -f ./../migration_sql/*.sql
# Initialize to create `schema_migrations` otherwise next migrations fail.
rails db:migrate:up VERSION=0;
mv -f ./../structure.sql V0__20150429224522__initialize.sql
rm -f ./../migration_sql/0_*.sql
i=1
for v in $(find * -type f -name '[[:digit:]]*_*.rb' ! -name '?_*'|cut -d _ -f 1| xargs echo);
do
    echo migrating $v
    rails db:migrate:up VERSION=$v;
    rails db:schema:dump;
    mv -f ./../structure.sql V${i}__${v}_schema_dump.sql;
    mv -f ./../migration_sql/${v}_*.sql V${i}__${v}_upgrade.sql;
    ((i++))
done
rails db:drop
rails db:create
```
