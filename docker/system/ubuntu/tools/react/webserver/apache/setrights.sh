OWNER=www-data
GROUP=www-data
RDIR=777
RFILE=666
STORAGE=/var/www/html/storage
BOOTSTRAP=/var/www/html/bootstrap/cache
function set_rights()
{
    echo $1
    echo $2
    echo $3
    echo ${OWNER}:${GROUP}
    find $1 -exec  chown -R ${OWNER}:${GROUP} {} \;
    find $1 -type d -exec  chmod $2 {} \;
    find $1 -type f -exec  chmod $3 {} \;
}

set_rights "${STORAGE}" "${RDIR}" "${RFILE}"
set_rights "${BOOTSTRAP}" "${RDIR}" "${RFILE}"

