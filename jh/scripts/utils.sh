function setup_database_yml_with_jh() {
  if [ "$DECOMPOSED_DB" == "true" ]; then
    if [ "$SEC_DECOMPOSED_DB" == "true" ]; then
      echo "Using SEC decomposed database config (jh/config/database.yml.decomposed-sec-postgresql)"
      cp jh/config/database.yml.decomposed-sec-postgresql config/database.yml
    else
      echo "Using decomposed database config (jh/config/database.yml.decomposed-postgresql)"
      cp jh/config/database.yml.decomposed-postgresql config/database.yml
    fi
  else
    echo "Using two connections, single database config (jh/config/database.yml.postgresql)"
    cp jh/config/database.yml.postgresql config/database.yml

    if [ "$CI_CONNECTION_DB" != "true" ]; then
      echo "Disabling ci connection in config/database.yml"
      sed -i "/ci:$/, /geo:$/ {s|^|#|;s|#  geo:|  geo:|;}" config/database.yml
    fi
  fi

  # Set up Geo database if the job name matches `rspec-ee` or `geo`.
  # Since Geo is an EE feature, we shouldn't set it up for non-EE tests.
  if [[ "${CI_JOB_NAME}" =~ "rspec-ee" ]] || [[ "${CI_JOB_NAME}" =~ "geo" ]] || [[ "${CI_JOB_NAME}" =~ "db:setup-ee" ]]; then
    echoinfo "Geo DB will be set up."
  else
    echoinfo "Geo DB won't be set up."
    sed -i '/geo:/,/^$/d' config/database.yml
  fi

  # Set up Embedding database if the job name matches `rspec-ee`
  # Since Embedding is an EE feature, we shouldn't set it up for non-EE tests.
  if [[ "${CI_JOB_NAME}" =~ "rspec-ee" ]] || [[ "${CI_JOB_NAME}" =~ "db:setup-ee" ]]; then
    echoinfo "Embedding DB will be set up."
  else
    echoinfo "Embedding DB won't be set up."
    sed -i '/embedding:/,/^$/d' config/database.yml
  fi

  # Set user to a non-superuser to ensure we test permissions
  sed -i 's/username: root/username: gitlab/g' config/database.yml

  sed -i 's/localhost/postgres/g' config/database.yml
  sed -i 's/username: git/username: postgres/g' config/database.yml
}
